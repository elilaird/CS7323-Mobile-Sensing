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
import cv2


class PrintHandlers(BaseHandler):
    def get(self):
        '''Write out to screen the handlers used
        This is a nice debugging example!
        '''
        self.set_header("Content-Type", "application/json")
        self.write(self.application.handlers_string.replace('),', '),\n'))


class UploadLabeledDatapointHandler(BaseHandler):
    def post(self):
        '''Save data point and class label to database
        '''
        data = json.loads(self.request.body.decode("utf-8"))

        vals = data['feature']
        fvals = [float(val) for val in vals]
        label = data['label']
        sess = data['dsid']

        dbid = self.db.labeledinstances.insert(
            {"feature": fvals, "label": label, "dsid": sess}
        )
        self.write_json({"id": str(dbid),
                         "feature": [str(len(fvals))+" Points Received",
                                     "min of: " + str(min(fvals)),
                                     "max of: " + str(max(fvals))],
                         "label": label})


class GetColorDeltaE(BaseHandler):
    def get(self):
        '''Save data point and class label to database
        '''
        desired_delta_e = self.get_float_arg("delta", default=0.0)

        colors = self._get_colors_with_delta_e(desired_delta_e)

        pair_names = ['PairA', 'PairB', 'PairC']

        def pair_constructor(color_pair):
            color_a, color_b = color_pair
            return {'colorA': str(color_a), 'colorB': str(color_b)}

        pair_info = {str(pair_name): pair_constructor(color_pair)
                     for pair_name, color_pair in zip(pair_names, colors)}

        self.write_json(pair_info)

    def _get_colors_with_delta_e(self, delta_e, n_colors=3):
        '''Return 3 pairs of colors that are different by the delta e amount

        Improvement for better delta e: 
        https://techkonusa.com/a-simple-review-of-cie-%CE%B4e-color-difference-equations/#:~:text=The%20intent%20of%20using%20%CE%94E,larger%20than%201%20is%20perceivable.


        Setting max delta E to 40 to avoid any errors or unexpected results.  This is because of the
        way I am creating new colors and a delta E of 40 is very distinguishable.  This will be 0 
        perceptibility score if it cannot be distinguished at this level
        '''
        if delta_e > 40:
            delta_e = 40

        return [self._get_color_with_delta_e(delta_e) for _ in range(n_colors)]

    def _calculate_delta_e(self, colorA, colorB):
        l1, a1, b1 = colorA
        l2, a2, b2 = colorB
        return np.sqrt((l1-l2)**2 + (a1-a2)**2 + (b1-b2)**2)

    def _scale_to_opencv(self, lab_color):
        l, a, b = lab_color
        return (l*(255/100), a+128, b+128)

    def _opencv_lab_to_lab(self, cv_lab_color):
        l, a, b = cv_lab_color
        return (l*100/255, a-128, b-128)

    def _rgb_to_opencv_lab(self, color):
        r, g, b = color

        # Convert to image so opencv can convert the color
        rgb_one_pix_image = np.array([[[r, g, b]]]).astype(
            np.uint8)  # opencv expects float32

        # Convert to lab and back to single pixel value
        l, a, b = np.squeeze(cv2.cvtColor(
            rgb_one_pix_image, cv2.COLOR_RGB2LAB)).astype(int)

        return (l, a, b)

    def _lab_to_rbg(self, lab_color):
        '''Converts lab color to an RGB color (assuming white point of: D65)

        OpenCV color range for LAB found here:
        https://rodrigoberriel.com/2014/11/opencv-color-spaces-splitting-channels/

        Note: setting the type to int might cause some bias in the measurements, but
        1 value in the rgb space should be relatively minimal to the human eye.
        '''

        # Since opencv uses scaled values for lab, need to scale lab to opencv values
        l, a, b = self._scale_to_opencv(lab_color)

        # Convert to image so opencv can convert the color
        lab_one_pix_image = np.array([[[l, a, b]]]).astype(
            np.uint8)  # opencv expects float32

        # Convert to rgb and back to single pixel value
        r, g, b = np.squeeze(cv2.cvtColor(
            lab_one_pix_image, cv2.COLOR_LAB2RGB)).astype(int)

        return r, g, b

    def _gen_random_lab_color(self):
        l = np.random.uniform(0, 100)
        a = np.random.uniform(-127, 127)
        b = np.random.uniform(-127, 127)
        return l, a, b

    def _change_channel_by(self, delta_e, start_color, edit_channel):

        new_color = list(start_color)
        new_channel_value = delta_e + start_color[edit_channel]

        if edit_channel == 0:
            # Range is 0 - 100
            if new_channel_value > 100:
                new_channel_value = start_color[edit_channel] - delta_e
            # Just for testing--validated
            assert 0 <= new_channel_value <= 100, 'Delta E on l channel is too large'
        else:
            # Range is -127 to 127
            if new_channel_value > 127:
                new_channel_value = start_color[edit_channel] - delta_e
            # Just for testing--validated
            assert -127 <= new_channel_value <= 127, 'Delta E on a or b channel is too large'

        new_color[edit_channel] = new_channel_value
        return tuple(new_color)

    def _get_color_with_delta_e(self, delta_e):
        random_channel_chosen = np.random.choice([0, 1, 2])

        # Generate random lab color
        start_color = self._gen_random_lab_color()

        # Make another color with the modified channel
        new_color = self._change_channel_by(
            delta_e, start_color, random_channel_chosen)

        # Make into rgb colors
        rgb_start = self._lab_to_rbg(start_color)
        rgb_end = self._lab_to_rbg(new_color)

        # Make sure rgb values are close enough to the delta e
        lab_a = self._opencv_lab_to_lab(self._rgb_to_opencv_lab(rgb_start))
        lab_b = self._opencv_lab_to_lab(self._rgb_to_opencv_lab(rgb_end))
        generated_delta_e = self._calculate_delta_e(lab_a, lab_b)

        # Make sure that the start and end colors (due to int conversions) are not the same
        # Also make sure casting back to rgb didn't make the colors too far apart
        if rgb_start == rgb_end or abs(generated_delta_e - delta_e) > .05:
            return self._get_color_with_delta_e(delta_e)

        # Return in random order to avoid patterns
        color_list = [rgb_start, rgb_end]
        np.random.shuffle(color_list)
        return color_list[0], color_list[1]


class RequestNewDatasetId(BaseHandler):
    def get(self):
        '''Get a new dataset ID for building a new dataset
        '''
        a = self.db.labeledinstances.find_one(sort=[("dsid", -1)])
        if a == None:
            newSessionId = 1
        else:
            newSessionId = float(a['dsid'])+1
        self.write_json({"dsid": newSessionId})


class UpdateModelForDatasetId(BaseHandler):
    def get(self):
        '''Train a new model (or update) for given dataset ID
        '''
        dsid = self.get_int_arg("dsid", default=0)
        model_type = self.get_str_arg("model_type", default="random_forest")

        data = self.get_features_and_labels_as_SFrame(dsid)

        # fit the model to the data
        acc = -1
        best_model = 'unknown'
        if len(data) > 0:

            # create models for comparison
            rf_model = tc.random_forest_classifier.create(
                data, target='target', verbose=0)
            log_model = tc.logistic_classifier.create(
                data, target='target', verbose=0)
            svm_model = tc.svm_classifier.create(
                data, target='target', verbose=0)

            # predict on each model
            rf_yhat = rf_model.predict(data)
            log_yhat = log_model.predict(data)
            svm_yhat = svm_model.predict(data)

            if model_type == 'random_forest':
                model = rf_model
            elif model_type == 'log':
                model = log_model
            elif model_type == 'svm':
                model = svm_model
            else:
                model = rf_model

            # set specified model
            self.clf[dsid] = {model_type: model}

            # calc accuracy for each model for comparison
            rf_acc = sum(rf_yhat == data['target'])/float(len(data))
            log_acc = sum(log_yhat == data['target'])/float(len(data))
            svm_acc = sum(svm_yhat == data['target'])/float(len(data))

            # save model for use later, if desired
            model.save('../models/turi_model_dsid%d_%s' % (dsid, model_type))
            model.export_coreml('../models/%s_coreml.mlmodel' % (model_type))

        # send back the resubstitution accuracy for each model
        self.write_json(
            {"rf_accuracy": rf_acc, "log_accuracy": log_acc, "svm_accuracy": svm_acc})

    def get_features_and_labels_as_SFrame(self, dsid):
        # create feature vectors from database
        features = []
        labels = []
        for a in self.db.labeledinstances.find({"dsid": dsid}):
            features.append([float(val) for val in a['feature']])
            labels.append(a['label'])

        # convert to dictionary for tc
        data = {'target': labels, 'sequence': np.array(features)}

        # send back the SFrame of the data
        return tc.SFrame(data=data)


class PredictOneFromDatasetId(BaseHandler):

    def _create_model(self, dsid, model_type, data):
        # create new model
        if model_type == "random_forest":
            model = tc.random_forest_classifier.create(
                data, target='target', verbose=0)
        elif model_type == 'log':
            model = tc.logistic_classifier.create(
                data, target='target', verbose=0)
        elif model_type == 'svm':
            model = tc.svm_classifier.create(data, target='target', verbose=0)
        else:
            model = tc.classifier.create(data, target='target', verbose=0)

        return model

    def post(self):
        '''Predict the class of a sent feature vector
        '''
        data = json.loads(self.request.body.decode("utf-8"))
        fvals = self.get_features_as_SFrame(data['feature'])
        dsid = data['dsid']
        model_type = data['model_type']

        data = self.get_features_and_labels_as_SFrame(dsid)

        if dsid not in self.clf:
            model = self._create_model(dsid, model_type, data)

            yhat = model.predict(data)
            self.clf[dsid] = {model_type: model}
            # save model for use later, if desired
            model.save('../models/turi_model_dsid%d_%s' % (dsid, model_type))

        if model_type not in self.clf[dsid]:
            model = self._create_model(dsid, model_type, data)
            yhat = model.predict(data)
            self.clf[dsid][model_type] = model
            # save model for use later, if desired
            model.save('../models/turi_model_dsid%d_%s' % (dsid, model_type))

        elif model_type in self.clf[dsid]:
            try:
                model = tc.load_model(
                    '../models/turi_model_dsid%d_%s' % (dsid, model_type))

            except Exception as e:
                print(
                    f'Error loading model {dsid}:{model_type} from file..\nCreating new instance...')
                model = self._create_model(dsid, model_type, data)
                yhat = model.predict(data)
                self.clf[dsid][model_type] = model
                # save model for use later, if desired
                model.save('../models/turi_model_dsid%d_%s' %
                           (dsid, model_type))

        predLabel = self.clf[dsid][model_type].predict(fvals)
        self.write_json({"prediction": str(predLabel)})

    def get_features_as_SFrame(self, vals):
        # create feature vectors from array input
        # convert to dictionary of arrays for tc

        tmp = [float(val) for val in vals]
        tmp = np.array(tmp)
        tmp = tmp.reshape((1, -1))
        data = {'sequence': tmp}

        # send back the SFrame of the data
        return tc.SFrame(data=data)

    def get_features_and_labels_as_SFrame(self, dsid):
        # create feature vectors from database
        features = []
        labels = []
        for a in self.db.labeledinstances.find({"dsid": dsid}):
            features.append([float(val) for val in a['feature']])
            labels.append(a['label'])

        # convert to dictionary for tc
        data = {'target': labels, 'sequence': np.array(features)}

        # send back the SFrame of the data
        return tc.SFrame(data=data)
