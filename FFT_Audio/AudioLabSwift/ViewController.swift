//
//  ViewController.swift
//  AudioLabSwift
//
//  Created by Eric Larson 
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit
import Metal


let AUDIO_BUFFER_SIZE = 16384


class ViewController: UIViewController {
    
    @IBOutlet weak var secondLoudestFrequency: UILabel!
    @IBOutlet weak var loudestFrequency: UILabel!
    // setup audio model
    let audio = AudioModel(buffer_size: AUDIO_BUFFER_SIZE)
    
    lazy var graph:MetalGraph? = {
        return MetalGraph(mainView: self.view)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Add graphs
        graph?.addGraph(withName: "fft",
                        shouldNormalize: true,
                        numPointsInGraph: AUDIO_BUFFER_SIZE/2)
        
        graph?.addGraph(withName: "time",
            shouldNormalize: false,
            numPointsInGraph: AUDIO_BUFFER_SIZE)
        
        //this is used for graph spacing
        graph?.addGraph(withName: "spaceholder",
                        shouldNormalize: false,
                        numPointsInGraph: 1)
        
        
        // start up the audio model here, querying microphone
        audio.startMicrophoneProcessing(withFps: 60.0)
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
        
        self.loudestFrequency.text = "\(self.audio.loudestFreq[0].rounded(.down)) Hz"
        self.secondLoudestFrequency.text = "\(self.audio.loudestFreq[1].rounded(.down)) Hz"
        
        // Make the labels not overflow
        loudestFrequency.adjustsFontSizeToFitWidth = true
        loudestFrequency.minimumScaleFactor = 0.2
        loudestFrequency.numberOfLines = 1
        
        secondLoudestFrequency.adjustsFontSizeToFitWidth = true
        secondLoudestFrequency.minimumScaleFactor = 0.2
        secondLoudestFrequency.numberOfLines = 1
        
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

