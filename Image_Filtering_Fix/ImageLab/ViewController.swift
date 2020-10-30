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
    
    var reading = false
    var flashOn = false
    
    var redColorBuffer: [Float] = []
    let redColorBufferSize = 256
    var bpmBuffer: [Float] = []
    let bpmBufferSize = 10
    
    //MARK: Outlets in view
    
    @IBOutlet weak var BPMLabel: UILabel!
    @IBOutlet weak var beginMeasurementButton: UIButton!
    
    
    lazy var graph:MetalGraph? = {
        return MetalGraph(mainView: self.view)
    }()
    
    private lazy var fftHelper:FFTHelper? = {
        return FFTHelper.init(fftSize: Int32(self.redColorBufferSize))
    }()
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        self.setupFilters()
        
        redColorBuffer = Array.init(repeating: 0.0, count: self.redColorBufferSize-1)
        //fftData = Array.init(repeating: 0.0, count: BUFFER_SIZE/2)
        //fftData = Array.init(repeating: 0.0, count: BUFFER_SIZE/2)
        
        graph?.addGraph(withName: "fft",
                        shouldNormalize: true,
                        numPointsInGraph: self.redColorBufferSize)
        
        
        self.videoManager = VideoAnalgesic(mainView: self.view)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        self.videoManager.setFPS(desiredFrameRate: 24.0)
        
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
        
        self.beginMeasurementButton.layer.cornerRadius = 10
        self.beginMeasurementButton.clipsToBounds = true
        
        self.bridge.processType = 1
        DispatchQueue.main.async {
            self.BPMLabel.text = ("Place Finger over Camera")
            self.beginMeasurementButton.isEnabled = false
            self.beginMeasurementButton.backgroundColor = UIColor.red
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.videoManager = nil
    }
    
    //MARK: Process image output
    func processFromCamera(inputImage:CIImage) -> CIImage{
        
        if !flashOn{
            _ = self.videoManager.toggleFlash()
            flashOn = true
        }
        
        var retImage = inputImage
        
        self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
        let finger = self.bridge.isFinger()
        
        // Activate Start Button if finger is present
        if !reading{
            if finger{
                DispatchQueue.main.async {
                    self.beginMeasurementButton.isEnabled = true
                    self.beginMeasurementButton.backgroundColor = UIColor.green
                }
            }else{
                DispatchQueue.main.async {
                    self.beginMeasurementButton.isEnabled = false
                    self.beginMeasurementButton.backgroundColor = UIColor.red
                }
            }
        }

        if reading {
            
            // Add the new average to our buffer
            let avgFromImage = self.bridge.processFinger()
            self.redColorBuffer.append(Float(avgFromImage![0]))
            
            // If the buffer is full
            if self.redColorBuffer.count == self.redColorBufferSize{
                var beats = 0
                let windowSize = 13
                var i = 0
                // Pad buffer for window
                let tempRedBuffer = Array.init(repeating: 0.0, count: Int(windowSize/2)) + self.redColorBuffer + Array.init(repeating: 0.0, count: Int(windowSize/2))
                
                // Sliding window to find peaks
                while(i<(redColorBufferSize)) {
                    //print(i)
                    let tempArr = tempRedBuffer[i...(i+windowSize-1)]
                    var max:Float = 0
                    var indexOfMax: UInt = 0
                    vDSP_maxvi(Array(tempArr), vDSP_Stride(1), &max, &indexOfMax, vDSP_Length(tempArr.count))
                    
                    if indexOfMax == 6{
                        beats += 1
                    }
                    i+=1
                }
                
                // Calculate BPM
                let secondsInBuffer = Float(self.redColorBufferSize)/24
                let newBPM = (Float(beats)/secondsInBuffer)*60.0
                
                // Append BPM to buffer
                if(newBPM > 40 && newBPM < 250){
                    bpmBuffer.append(newBPM)
                    if(bpmBuffer.count > bpmBufferSize){
                        bpmBuffer.removeFirst(1)
                    }
                }
                
                // Take average of last few bpm estimates
                var totalBpm = (bpmBuffer.reduce(0, +))/Float(bpmBuffer.count)
                if totalBpm.isNaN || totalBpm.isInfinite{
                    totalBpm = 0
                    DispatchQueue.main.async {
                        self.BPMLabel.text = ("Reading ...")
                    }
                }else if !finger{
                    DispatchQueue.main.async {
                        self.BPMLabel.text = ("Finger Removed")
                    }
                }else{
                    DispatchQueue.main.async {
                        self.BPMLabel.text = ("\(Int(totalBpm)) BPM")
                    }
                }
                
                // Deque oldest reading to make room for a new one
                self.redColorBuffer = Array(self.redColorBuffer[1...])
                self.updateGraph()
                
            }
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
        self.reading = true
        self.beginMeasurementButton.setTitle("Reading Heart Rate", for: .normal)
        self.beginMeasurementButton.isEnabled = false
    }
    
    
    @objc
    func updateGraph(){
        self.graph?.updateGraph(
            data: self.redColorBuffer.map({$0 - 300}),
            forKey: "fft"
        )
        
    }
}

