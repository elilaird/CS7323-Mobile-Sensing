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
    
    var redBuffer:[Float] = []
    var greenBuffer:[Float] = []
    var blueBuffer:[Float] = []
    
    var redFFT:[Float] = []
    var greenFFT:[Float] = []
    var blueFFT:[Float] = []
    
    var finger: Bool = false
    var pulseGraph:[Float] = []
    var currentState: Bool = false
    var fingerBuffer: [Bool]! = nil
    var frameCtr: Int = 0
    var bufferSize = 100
    
    //MARK: Outlets in view
    
    
    
    lazy var graph:MetalGraph? = {
        return MetalGraph(mainView: self.view)
    }()
    
    private lazy var fftHelper:FFTHelper? = {
        return FFTHelper.init(fftSize: Int32(self.bufferSize))
    }()
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        self.setupFilters()
        
        redFFT = Array.init(repeating: 0.0, count: bufferSize/2)
        //fftData = Array.init(repeating: 0.0, count: BUFFER_SIZE/2)
        //fftData = Array.init(repeating: 0.0, count: BUFFER_SIZE/2)
        
        graph?.addGraph(withName: "fft",
                        shouldNormalize: true,
                        numPointsInGraph: 50)
        
        pulseGraph = Array.init(repeating: 0.0, count: self.bufferSize)
        
        self.videoManager = VideoAnalgesic(mainView: self.view)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        self.videoManager.setFPS(desiredFrameRate: 60.0)
        
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
        let frameColors = self.bridge.processFinger()
        if(redBuffer.count >= bufferSize){
            //Insert and shift
            redBuffer.removeFirst(1)
            greenBuffer.removeFirst(1)
            blueBuffer.removeFirst(1)
            redBuffer.append(Float((frameColors?[0])!))
            greenBuffer.append(Float((frameColors?[1])!))
            blueBuffer.append(Float((frameColors?[2])!))
            
        }else{
            //Insert until buffers are full
            redBuffer.append(Float((frameColors?[0])!))
            greenBuffer.append(Float((frameColors?[1])!))
            blueBuffer.append(Float((frameColors?[2])!))
        }
        
        if(redBuffer.count == bufferSize){
            fftHelper!.performForwardFFT(withData: &redBuffer,
                                         andCopydBMagnitudeToBuffer: &redFFT)
            print(redFFT)
            self.updateGraph()
        }
        
        //self.updateGraph()
        
        retImage = self.bridge.getImage()
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
    @IBAction func toggleFlash(_ sender: UIButton) {
        self.videoManager.toggleFlash()
    }
    
    
    @objc
    func updateGraph(){
        
        //let zoomedData = Array(self.bridge.redBuffer as! [Float]).map({$0 - 350})
        self.graph?.updateGraph(
            data: self.redFFT.map({$0 - 100}),
            forKey: "fft"
        )
        
    }
}

