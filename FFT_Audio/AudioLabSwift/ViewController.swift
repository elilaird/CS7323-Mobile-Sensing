//
//  ViewController.swift
//  AudioLabSwift
//
//  Created by Eric Larson 
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit
import Metal


let AUDIO_BUFFER_SIZE = 1024*4


class ViewController: UIViewController {

    // setup audio model
    let audio = AudioModel(buffer_size: AUDIO_BUFFER_SIZE)
    
    lazy var graph:MetalGraph? = {
        return MetalGraph(mainView: self.view)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // add in graphs for display
        graph?.addGraph(withName: "equalizer",
                        shouldNormalize: true,
                        numPointsInGraph: 20)
        
        graph?.addGraph(withName: "fft",
                        shouldNormalize: true,
                        numPointsInGraph: AUDIO_BUFFER_SIZE/2)
        
        graph?.addGraph(withName: "time",
            shouldNormalize: false,
            numPointsInGraph: AUDIO_BUFFER_SIZE)
        let pf = PeakFinder(buffer_size: 1024, fftArray: [1.0, 1.20], samplingFrequency: 55.5)
        pf.getPeakFrequencies(withFl: nil, withFh: nil)
        
        
        
        
        // start up the audio model here, querying microphone
//        audio.startMicrophoneProcessing(withFps: 10)
//        audio.startMicrophoneProcessing(withFps: 10)
        audio.startSongMicrophoneProcessing(withFps: 10)

        audio.play()
        
        // run the loop for updating the graph peridocially
        Timer.scheduledTimer(timeInterval: 0.05, target: self,
            selector: #selector(self.updateGraph),
            userInfo: nil,
            repeats: true)
       
    }
    
    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)

        audio.pause()
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        audio.play()
    }
    
    // periodically, update the graph with refreshed FFT Data
    @objc
    func updateGraph(){
        
        self.graph?.updateGraph(
            data: self.audio.dataEqualizer,
            forKey: "equalizer")

        
        self.graph?.updateGraph(
            data: self.audio.fftData,
            forKey: "fft"
        )
        
        self.graph?.updateGraph(
            data: self.audio.timeData,
            forKey: "time"
        )
        
    }
    
    

}

