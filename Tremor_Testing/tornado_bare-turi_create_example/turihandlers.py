#!/usr/bin/python

from pymongo import MongoClient
import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

from basehandler import BaseHandler

import turicreate as tc
import pickle
from bson.binary import Binary
import json
import numpy as np

class PrintHandlers(BaseHandler):
    def get(self):
        '''Write out to screen the handlers used
        This is a nice debugging example!
        '''
        self.set_header("Content-Type", "application/json")
        self.write(self.application.handlers_string.replace('),','),\n'))

class UploadLabeledDatapointHandler(BaseHandler):
    def post(self):
        '''Save data point and class label to database
        '''
        data = json.loads(self.request.body.decode("utf-8"))

        vals = data['feature']
        fvals = [float(val) for val in vals]
        label = data['label']
        sess  = data['dsid']

        dbid = self.db.labeledinstances.insert(
            {"feature":fvals,"label":label,"dsid":sess}
            );
        self.write_json({"id":str(dbid),
            "feature":[str(len(fvals))+" Points Received",
                    "min of: " +str(min(fvals)),
                    "max of: " +str(max(fvals))],
            "label":label})

class RequestNewDatasetId(BaseHandler):
    def get(self):
        '''Get a new dataset ID for building a new dataset
        '''
        a = self.db.labeledinstances.find_one(sort=[("dsid", -1)])
        if a == None:
            newSessionId = 1
        else:
            newSessionId = float(a['dsid'])+1
        self.write_json({"dsid":newSessionId})

class UpdateModelForDatasetId(BaseHandler):
    def get(self):
        '''Train a new model (or update) for given dataset ID
        '''
        dsid = self.get_int_arg("dsid",default=0)
        model_type = self.get_str_arg("model_type",default="random_forest")

        data = self.get_features_and_labels_as_SFrame(dsid)

        # fit the model to the data
        acc = -1
        best_model = 'unknown'
        if len(data)>0:

            if model_type == "random_forest":
                model = tc.random_forest_classifier.create(data,target='target',verbose=0)
            elif model_type == 'knn':
                model = tc.nearest_neighbor_classifier.create(data,target='target',distance='auto',verbose=0)
            elif model_type == 'svm':
                model = tc.svm_classifier.create(data,target='target',verbose=0)
            else:
                model = tc.classifier.create(data,target='target',verbose=0)

            yhat = model.predict(data)
            self.clf[dsid] = {model_type:model}
            acc = sum(yhat==data['target'])/float(len(data))
            # save model for use later, if desired
            model.save('../models/turi_model_dsid%d_%s'%(dsid, model_type))


        # send back the resubstitution accuracy
        # if training takes a while, we are blocking tornado!! No!!
        self.write_json({"resubAccuracy":acc})

    def get_features_and_labels_as_SFrame(self, dsid):
        # create feature vectors from database
        features=[]
        labels=[]
        for a in self.db.labeledinstances.find({"dsid":dsid}):
            features.append([float(val) for val in a['feature']])
            labels.append(a['label'])

        # convert to dictionary for tc
        data = {'target':labels, 'sequence':np.array(features)}

        # send back the SFrame of the data
        return tc.SFrame(data=data)

class PredictOneFromDatasetId(BaseHandler):

    def _create_model(self, dsid, model_type, data):
        #create new model
        if model_type == "random_forest":
            model = tc.random_forest_classifier.create(data,target='target',verbose=0)
        elif model_type == 'knn':
            model = tc.nearest_neighbor_classifier.create(data,target='target',distance='auto',verbose=0)
        elif model_type == 'svm':
            model = tc.svm_classifier.create(data,target='target',verbose=0)
        else:
            model = tc.classifier.create(data,target='target',verbose=0)

        return model

    def post(self):
        '''Predict the class of a sent feature vector
        '''
        data = json.loads(self.request.body.decode("utf-8"))
        fvals = self.get_features_as_SFrame(data['feature'])
        dsid  = data['dsid']
        model_type = data['model_type']

        data = self.get_features_as_SFrame(fvals)

        if dsid not in self.clf:
            model = self._create_model(dsid, model_type, data)

            yhat = model.predict(data)
            self.clf[dsid][model_type] = model
            # save model for use later, if desired
            model.save('../models/turi_model_dsid%d_%s'%(dsid, model_type))

        if model_type not in self.clf[dsid]:
            model = self._create_model(dsid, model_type, data)
            yhat = model.predict(data)
            self.clf[dsid][model_type] = model
            # save model for use later, if desired
            model.save('../models/turi_model_dsid%d_%s'%(dsid, model_type))

        elif model_type in self.clf[dsid]:
            try:
                model = tc.load_model('../models/turi_model_dsid%d_%s'%(dsid, model_type))

            except Exception as e:
                print(f'Error loading model {dsid}:{model_type} from file..\nCreating new instance...')
                model = self._create_model(dsid, model_type, data)
                yhat = model.predict(data)
                self.clf[dsid][model_type] = model
                # save model for use later, if desired
                model.save('../models/turi_model_dsid%d_%s'%(dsid, model_type))

        predLabel = self.clf[dsid][model_type].predict(fvals);
        self.write_json({"prediction":str(predLabel)})

    def get_features_as_SFrame(self, vals):
        # create feature vectors from array input
        # convert to dictionary of arrays for tc

        tmp = [float(val) for val in vals]
        tmp = np.array(tmp)
        tmp = tmp.reshape((1,-1))
        data = {'sequence':tmp}

        # send back the SFrame of the data
        return tc.SFrame(data=data)
