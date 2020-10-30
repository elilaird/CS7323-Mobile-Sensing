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
    
    var redColorBuffer: [Float] = []
    let redColorBufferSize = 256
    var blueColorBuffer: [Float] = []
    let blueColorBufferSize = 256
    var bpmBuffer: [Float] = []
    let bpmBufferSize = 10
    
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
        
        redFFT = Array.init(repeating: 0.0, count: 128)
        //fftData = Array.init(repeating: 0.0, count: BUFFER_SIZE/2)
        //fftData = Array.init(repeating: 0.0, count: BUFFER_SIZE/2)
        
        graph?.addGraph(withName: "fft",
                        shouldNormalize: true,
                        numPointsInGraph: self.redColorBufferSize)
        
        pulseGraph = Array.init(repeating: 0.0, count: self.redColorBufferSize)
        
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

        let avgFromImage = self.bridge.processFinger()
        
        // Add the new average to our buffer
        self.redColorBuffer.append(Float(avgFromImage![0]))
        self.blueColorBuffer.append(Float(avgFromImage![2]))
        
        
        // If the buffer is full
        if self.redColorBuffer.count == self.redColorBufferSize{
            var beats = 0
            let windowSize = 11
            for i in 0..<(redColorBufferSize-windowSize) {
                let tempArr = self.redColorBuffer[i...(i+windowSize)]
                var max:Float = 0
                var indexOfMax: UInt = 0
                vDSP_maxvi(Array(tempArr), vDSP_Stride(1), &max, &indexOfMax, vDSP_Length(tempArr.count))
                
                if indexOfMax == 5{
                    beats += 1
                }
            }
            /*
            // Get the average color
            let rAvg = self.redColorBuffer.reduce(0, {$0 + $1})/Float(self.redColorBuffer.count)
            let bAvg = self.blueColorBuffer.reduce(0, {$0 + $1})/Float(self.blueColorBuffer.count)

            // Initialize counters
            var rinARowBelowAvg = 0
            var rtotalsInARow = 0
            var binARowBelowAvg = 0
            var btotalsInARow = 0
            for red in self.redColorBuffer{
                if red < rAvg{
                    // Add to the count of numbers below average in a row
                    rinARowBelowAvg = rinARowBelowAvg + 1
                }else{
                    // Make sure we didn't just get a random sample that was below the average
                    if rinARowBelowAvg > 10{
                        // Add as a beat
                        rtotalsInARow = rtotalsInARow + 1
                    }else{
                    }
                    // Reset counter
                    rinARowBelowAvg = 0
                }
            }
            for blue in self.blueColorBuffer{
                if blue < bAvg{
                    // Add to the count of numbers below average in a row
                    binARowBelowAvg = binARowBelowAvg + 1
                }else{
                    // Make sure we didn't just get a random sample that was below the average
                    if binARowBelowAvg > 7{
                        // Add as a beat
                        btotalsInARow = btotalsInARow + 1
                    }
                    // Reset counter
                    binARowBelowAvg = 0
                }
            }
            */
            let secondsInBuffer = Float(self.redColorBufferSize)/60.0
            //let beatsInBuffer = (rtotalsInARow + btotalsInARow)/3
            // BPS to BPM
            let newBPM = (Float(beats)/secondsInBuffer)*60.0
            //let rBPM = (Float(rtotalsInARow)/secondsInBuffer)*60.0
            //let bBPM = (Float(btotalsInARow)/secondsInBuffer)*60.0
            
            if(newBPM > 40 && newBPM < 250){
                bpmBuffer.append(newBPM/2)
                if(bpmBuffer.count > bpmBufferSize){
                    bpmBuffer.removeFirst(1)
                }
            }
            
            let totalBpm = (bpmBuffer.reduce(0, +))/Float(bpmBuffer.count)
            
            print("******************\n")
            //print(rBPM, bBPM)
            print("new bpm: \(totalBpm)")
            print("******************\n")
            
            // Deque oldest reading to make room for a new one
            self.redColorBuffer = Array(self.redColorBuffer[1...])
            self.updateGraph()
            
        }
        
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
            data: self.redColorBuffer.map({$0 - 300}),
            forKey: "fft"
        )
        
    }
}

