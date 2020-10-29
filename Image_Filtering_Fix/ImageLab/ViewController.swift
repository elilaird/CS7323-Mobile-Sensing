//
//  ViewController.swift
//  ImageLab
//
//  Created by Eric Larson
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController   {

    //MARK: Class Properties
    var filters : [CIFilter]! = nil
    var videoManager:VideoAnalgesic! = nil
    var detector:CIDetector! = nil
    
    let pinchFilterIndex = 2
    let bridge = OpenCVBridge()
    
    var finger: Bool = false
    var currentState: Bool = false
    var fingerBuffer: [Bool]! = nil
    var frameCtr: Int = 0
    
    //MARK: Outlets in view
    @IBOutlet weak var flashSlider: UISlider!
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        self.setupFilters()
        
        self.videoManager = VideoAnalgesic(mainView: self.view)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        self.videoManager.setFPS(desiredFrameRate: 30.0)
        
        self.fingerBuffer = Array.init(repeating: false, count: 36)
        
        // create dictionary for face detection
        // HINT: you need to manipulate these proerties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow]
        
        // setup a face detector in swift
        self.detector = CIDetector(ofType: CIDetectorTypeFace,
                                  context: self.videoManager.getCIContext(), // perform on the GPU if possible
                                  options: optsDetector)
        
        self.bridge.setTransforms(self.videoManager.transform)
        self.videoManager.setProcessingBlock(newProcessBlock: self.processFromCamera)
        
        
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        
        self.bridge.processType = 1
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.videoManager = nil
    }
    
    //MARK: Process image output
    func processFromCamera(inputImage:CIImage) -> CIImage{
        
        var retImage = inputImage
        
        // use this code if you are using OpenCV and want to overwrite the displayed image via OpenCv
        // this is a BLOCKING CALL
        self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
        //self.bridge.processImage()
        self.finger = self.bridge.processFinger()

        
        /*
        if(frameCtr == 36){
            frameCtr = 0
        }
        var enoughFingers = false
        if(fingerBuffer.filter{$0}.count >= 1){
            enoughFingers = true
        }
        if (enoughFingers && !currentState){
            _ = self.videoManager.toggleFlash()
            self.currentState = true
        }else if(currentState && !enoughFingers){
            _ = self.videoManager.toggleFlash()
            self.currentState = false
        }*/
    
        
        retImage = self.bridge.getImage()
        
        //HINT: you can also send in the bounds of the face to ONLY process the face in OpenCV
        // or any bounds to only process a certain bounding region in OpenCV
        
        return retImage
    }
    
    //MARK: Setup filtering
    func setupFilters(){
        filters = []
        
        let filterPinch = CIFilter(name:"CIBumpDistortion")!
        filterPinch.setValue(-0.5, forKey: "inputScale")
        filterPinch.setValue(75, forKey: "inputRadius")
        filters.append(filterPinch)
        
    }
    
    //MARK: Convenience Methods for UI Flash and Camera Toggle
    @IBAction func flash(sender: AnyObject) {
        if(!self.finger){
            if(self.videoManager.toggleFlash()){
                self.flashSlider.value = 1.0
            }
            else{
                self.flashSlider.value = 0.0
            }
            
        }
    }
    
    
    @IBAction func switchCamera(sender: AnyObject) {
        if (!self.finger){
            self.videoManager.toggleCameraPosition()
        }
    }
    
    @IBAction func setFlashLevel(sender: UISlider) {
        // Examples for usign the flash
        if(sender.value>0.0){
            // max value is 1.0
            self.videoManager.turnOnFlashwithLevel(sender.value)
        }
        else if(sender.value==0.0){
            self.videoManager.turnOffFlash()
        }
    }

   
}

