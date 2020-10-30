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
    var pulseGraph:[Float] = []
    var currentState: Bool = false
    var fingerBuffer: [Bool]! = nil
    var frameCtr: Int = 0
    var bufferSize = 100
    var redColorBuffer: [Float] = []
    let redColorBufferSize = 256
    
    
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
//        self.setupFilters()
        
        graph?.addGraph(withName: "fft",
                        shouldNormalize: true,
                        numPointsInGraph: 100)
        
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

        let avgRedFromImage = self.bridge.processFinger()
        
        // Add the new average to our buffer
        self.redColorBuffer.append(Float(avgRedFromImage))
        
        // If the buffer is full
        if self.redColorBuffer.count == self.redColorBufferSize{

            // Get the average color
            let avg = self.redColorBuffer.reduce(0, {$0 + $1})/Float(self.redColorBuffer.count)

            // Initialize counters
            var inARowBelowAvg = 0
            var totalsInARow = 0
            for red in self.redColorBuffer{
                if red < avg{
                    // Add to the count of numbers below average in a row
                    inARowBelowAvg = inARowBelowAvg + 1
                }else{
                    // Make sure we didn't just get a random sample that was below the average
                    if inARowBelowAvg > 4{
                        // Add as a beat
                        totalsInARow = totalsInARow + 1
                    }
                    // Reset counter
                    inARowBelowAvg = 0
                }
            }
            let secondsInBuffer = Float(self.redColorBufferSize)/60.0
            let beatsInBuffer = totalsInARow
            // BPS to BPM
            let newBPM = (Float(beatsInBuffer)/secondsInBuffer)*60.0
            
            print("******************\n")
            print("new bpm: \(newBPM)")
            print("******************\n")
            
            // Deque oldest reading to make room for a new one
            self.redColorBuffer = Array(self.redColorBuffer[1...])
            
        }
        
        retImage = self.bridge.getImage()
        return retImage
    }
    
    @IBAction func flashToggle(_ sender: UIButton) {
        _ = self.videoManager.toggleFlash()
    }
    
    @objc
    func updateGraph(){
        
        let zoomedData = Array(self.bridge.redBuffer as! [Float]).map({$0 - 350})
        
        self.graph?.updateGraph(
            data: zoomedData,
            forKey: "fft"
        )
        
    }

   
}

