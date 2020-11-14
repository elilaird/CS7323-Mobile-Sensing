//
//  ViewController.swift
//  HTTPSwiftExample
//
//  Created by Eric Larson on 3/30/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

// This exampe is meant to be run with the python example:
//              tornado_example.py 
//              from the course GitHub repository: tornado_bare, branch sklearn_example


// if you do not know your local sharing server name try:
//    ifconfig |grep inet   
// to see what your public facing IP address is, the ip address can be used here
//let SERVER_URL = "http://erics-macbook-pro.local:8000" // change this for your server name!!!
let SERVER_URL = "http://35.239.233.247:8000" // change this for your server name!!!

import UIKit
import CoreMotion
import CoreML
import Vision

class ViewController: UIViewController, URLSessionDelegate {
    
    // MARK: Class Properties
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        
        return URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
    }()
    @IBOutlet weak var updateModelButton: UIButton!
    
    let operationQueue = OperationQueue()
    let motionOperationQueue = OperationQueue()
    let calibrationOperationQueue = OperationQueue()
    
    var ringBuffer = RingBuffer()
    let animation = CATransition()
    let motion = CMMotionManager()
    
    var magValue = 0.1
    var isCalibrating = false
    var isReady = false
    
//    lazy var loadedRFModel: random_forest_coreml = random_forest_coreml()
//    let model = try VNCoreMLModel(for: random_forest_coreml().model)
    lazy var model:random_forest_coreml = {
            do{
                let config = MLModelConfiguration()
                return try random_forest_coreml(configuration: config)
            }catch{
                print(error)
                fatalError("Could not load Resnet50")
            }
        }()
    
    var isWaitingForMotionData = false
    

    @IBOutlet weak var dsidLabel: UILabel!

    @IBOutlet weak var modelSelecter: UISegmentedControl!
    @IBOutlet weak var largeMotionMagnitude: UIProgressView!
    @IBOutlet weak var handImageView: UIImageView!
    @IBOutlet weak var defaultHandImageView: UIImageView!
    @IBOutlet weak var tableImageView: UIImageView!
    
    @IBOutlet weak var predictingLabel: UILabel!
    @IBOutlet weak var layDownTableLabel: UILabel!
    @IBOutlet weak var holdPhoneLabel: UILabel!
    @IBOutlet weak var rfAccLabel: UILabel!
    @IBOutlet weak var svmAccLabel: UILabel!
    @IBOutlet weak var logAccLabel: UILabel!
    @IBOutlet weak var loadedAccLabel: UILabel!
    
    var buttonIsReady = false
    
    @IBAction func isReadyButtonClicked(_ sender: Any) {
        self.buttonIsReady = true
    }
    
    // MARK: Class Properties with Observers
    enum CalibrationStage {
        case notCalibrating
        case table
        case hand
    }
    
    var calibrationStage:CalibrationStage = .notCalibrating {
        didSet{
            switch calibrationStage {
            case .table:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.predictingLabel.isHidden = true
                    self.setAsCalibrating(self.tableImageView, label: self.layDownTableLabel)
                    self.setAsNormal(self.handImageView, label: self.holdPhoneLabel)
                }
                break
            case .hand:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.predictingLabel.isHidden = true
                    self.setAsNormal(self.tableImageView, label: self.layDownTableLabel)
                    self.setAsCalibrating(self.handImageView, label: self.holdPhoneLabel)
                }
                break
            case .notCalibrating:
                self.isCalibrating = false
                DispatchQueue.main.async{
                    self.setAsNormal(self.tableImageView, label: self.layDownTableLabel)
                    self.setAsNormal(self.handImageView, label: self.holdPhoneLabel)
                    self.defaultHandImageView.isHidden = false
                    self.predictingLabel.isHidden = false
                }
                break
            }
        }
    }
    
    var dsid:Int = 0 {
        didSet{
            DispatchQueue.main.async{
                // update label when set
                self.dsidLabel.layer.add(self.animation, forKey: nil)
                self.dsidLabel.text = "Current DSID: \(self.dsid)"
            }
        }
    }
    
    var model_type:String = "random_forest"
    
    @IBAction func changeModel(_ sender: Any) {
        let selectedModel = self.modelSelecter.titleForSegment(at: self.modelSelecter.selectedSegmentIndex)!
        
        switch selectedModel {
        case "RF":
            self.model_type = "random_forest"
        case "SVM":
            self.model_type = "svm"
        case "Log":
            self.model_type = "log"
        case "Loaded":
            self.model_type = "loaded"
        default:
            self.model_type = "random_forest"
        }
    }
    
    // MARK: Core Motion Updates
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 1.0/200
            self.motion.startDeviceMotionUpdates(to: motionOperationQueue, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let accel = motionData?.userAcceleration {
            self.ringBuffer.addNewData(xData: accel.x, yData: accel.y, zData: accel.z)
            let mag = fabs(accel.x)+fabs(accel.y)+fabs(accel.z)
            
            DispatchQueue.main.async{
                //show magnitude via indicator
                self.largeMotionMagnitude.progress = Float(mag)/0.2
            }
            
            if self.buttonIsReady{
                // buffer up a bit more data and then notify of occurrence
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    self.buttonIsReady = false
                    self.calibrationOperationQueue.addOperation {
                        // something large enough happened to warrant
                        self.largeMotionEventOccurred()
                    }
                })
            }

        }
    }
    
    
    //MARK: Calibration procedure
    func largeMotionEventOccurred(){
        if(self.isCalibrating){
            //send a labeled example
            if(self.calibrationStage != .notCalibrating && self.isWaitingForMotionData)
            {
                self.isWaitingForMotionData = false
                
                // send data to the server with label
                sendFeatures(self.ringBuffer.getDataAsVector(),
                             withLabel: self.calibrationStage)
                
                self.nextCalibrationStage()
            }
        }
        else
        {
            if(self.isWaitingForMotionData)
            {
                self.isWaitingForMotionData = false
                //predict a label
                getPrediction(self.ringBuffer.getDataAsVector())
                // dont predict again for a bit
                setDelayedWaitingToTrue(2.0)
                
            }
        }
    }
    
    func nextCalibrationStage(){
        switch self.calibrationStage {
        case .notCalibrating:
            //start with table
            self.calibrationStage = .table
            setDelayedWaitingToTrue(3.0)
            break
        case .table:
            //go to hand
            self.calibrationStage = .hand
            setDelayedWaitingToTrue(3.0)
            break
        case .hand:
            //end calibration
            self.calibrationStage = .notCalibrating
            setDelayedWaitingToTrue(1.0)
            break
        }
    }
    
    func setDelayedWaitingToTrue(_ time:Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            self.isWaitingForMotionData = true
        })
    }
    
    func setAsCalibrating(_ image: UIImageView, label: UILabel){
        self.defaultHandImageView.isHidden = true
        image.isHidden = false
        label.isHidden = false
    }
    
    func setAsNormal(_ image: UIImageView, label: UILabel?){
        image.isHidden = true
        if label != nil{
            label!.isHidden = true
        }
    }
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // create reusable animation
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = 0.5
        
        
        // setup core motion handlers
        startMotionUpdates()
        
        dsid = 1 // set this and it will update UI
    }

    //MARK: Get New Dataset ID
    @IBAction func getDataSetId(_ sender: AnyObject) {
        // create a GET request for a new DSID from server
        let baseURL = "\(SERVER_URL)/GetNewDatasetId"
        
        let getUrl = URL(string: baseURL)
        let request: URLRequest = URLRequest(url: getUrl!)
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    print("Response:\n%@",response!)
                }
                else{
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    
                    // This better be an integer
                    if let dsid = jsonDictionary["dsid"]{
                        self.dsid = dsid as! Int
                    }
                }
                
        })
        
        dataTask.resume() // start the task
        
    }
    
    //MARK: Calibration
    @IBAction func startCalibration(_ sender: AnyObject) {
        self.isWaitingForMotionData = false // dont do anything yet
        nextCalibrationStage()
        
    }
    
    //MARK: Comm with Server
    func sendFeatures(_ array:[Double], withLabel label:CalibrationStage){
        let baseURL = "\(SERVER_URL)/AddDataPoint"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["feature":array,
                                       "label":"\(label)",
                                       "dsid":self.dsid]
        
        print(jsonUpload)
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    
                    print(jsonDictionary["feature"]!)
                    print(jsonDictionary["label"]!)
                }

        })
        
        postTask.resume() // start the task
    }
    
    func getPrediction(_ array:[Double]){
        
        if self.model_type != "loaded"{
            let baseURL = "\(SERVER_URL)/PredictOne"
            let postUrl = URL(string: "\(baseURL)")

            // create a custom HTTP POST request
            var request = URLRequest(url: postUrl!)

            // data to send in body of post request (send arguments as json)
            let jsonUpload:NSDictionary = ["feature":array, "dsid":self.dsid, "model_type":self.model_type]


            let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)

            request.httpMethod = "POST"
            request.httpBody = requestBody

            let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                      completionHandler:{
                            (data, response, error) in
                            if(error != nil){
                                if let res = response{
                                    print("Response:\n",res)
                                }
                            }
                            else{ // no error we are aware of
                                let jsonDictionary = self.convertDataToDictionary(with: data)

                                if let labelResponse = jsonDictionary["prediction"]{
                                    print(labelResponse)
                                    self.displayLabelResponse(labelResponse as! String)
                                }

                            }

            })
            
            postTask.resume() // start the task
        }else{
            do{
                var pred = try self.model.prediction(input: random_forest_coremlInput(sequence: MLMultiArray(array))).target
                pred = "['\(pred)']"
                self.displayLabelResponse(pred)
            }catch {
                print(error)
              }
            
            
        }
        
    }
    
    //interpret results from vision query
    func resultsMethod(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation]
            else {
                fatalError("Could not cast request as classification object")
        }
        
        // Add in results display...
        print("---------------")
        for result in results {
            if(result.confidence > 0.05){
                print(result.identifier,result.confidence)
            }
        }
        
    }
    
    func displayLabelResponse(_ response:String){
        switch response {
        case "['table']":
            blinkLabel(tableImageView)
            break
        case "['hand']":
            blinkLabel(handImageView)
            break
        default:
            print("Unknown")
            break
        }
    }
    
    func blinkLabel(_ image:UIImageView){
        DispatchQueue.main.async {
            self.setAsCalibrating(image, label: self.predictingLabel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.setAsNormal(image, label: nil)
            })
        }
        
    }
    
    @IBAction func makeModel(_ sender: AnyObject) {
        
        // create a GET request for server to update the ML model with current data
        let baseURL = "\(SERVER_URL)/UpdateModel"
        let query = "?dsid=\(self.dsid)&model_type=\(self.model_type)"
        
        let getUrl = URL(string: baseURL+query)
        let request: URLRequest = URLRequest(url: getUrl!)
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
              completionHandler:{(data, response, error) in
                // handle error!
                if (error != nil) {
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    
                    if let resubAcc = jsonDictionary["resubAccuracy"]{
                        print("Resubstitution Accuracy is", resubAcc)
                    }
                    
                    // update acc labels
                    if let rfAcc = (jsonDictionary["rf_accuracy"] as? NSNumber)?.floatValue {
                        print("Rf acc: \(rfAcc)")
                        let acc = Int(rfAcc * Float(100))
                        DispatchQueue.main.async{
                            self.rfAccLabel.text = "\(acc)%"
                        }
                    }
                    if let svmAcc = (jsonDictionary["svm_accuracy"] as? NSNumber)?.floatValue {
                        print("svm acc: \(svmAcc)")
                        let acc = Int(svmAcc * Float(100))
                        DispatchQueue.main.async{
                            self.svmAccLabel.text = "\(acc)%"
                        }
                    
                    }
                    if let logAcc = (jsonDictionary["log_accuracy"] as? NSNumber)?.floatValue{
                        print("log acc: \(logAcc)")
                        let acc = Int(logAcc * Float(100))
                        DispatchQueue.main.async{
                            self.logAccLabel.text = "\(acc)%"
                        }
                        
                    }
                }
                                                                    
        })
        
        dataTask.resume() // start the task
        
    }
    
    //MARK: JSON Conversion Functions
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                              options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            
            if let strData = String(data:data!, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                            print("printing JSON received as string: "+strData)
            }else{
                print("json error: \(error.localizedDescription)")
            }
            return NSDictionary() // just return empty
        }
    }

}





