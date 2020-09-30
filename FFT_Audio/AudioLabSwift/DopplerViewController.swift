//
//  DopplerViewController.swift
//  AudioLabSwift
//
//  Created by Matthew Lee on 9/27/20.
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit

class DopplerViewController: UIViewController {
    
    // Initialize buffers and view elements
    let audio = AudioModel(buffer_size: 16384)
    let freqSlider = UISlider(frame:CGRect(x: 0, y: 0, width: 300, height: 20))
    let freqLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    let dopplerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    let graphView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    // Starting freq higher than 15000 so it doesn't hurt ears
    var dopplerFrequency:Float = 15000
    
    lazy var graph:MetalGraph? = {
        return MetalGraph(mainView: self.graphView)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up graph
        self.graphView.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height/6)
        self.graphView.backgroundColor = UIColor(named: "blue")
        
        self.view.addSubview(graphView)
        graph?.addGraph(withName: "microphoneDataDecibels",
                        shouldNormalize: true,
                        numPointsInGraph: 2300)
        
        // Set up frequency slider
        freqSlider.center = self.view.center
        freqSlider.minimumValue = 15000
        freqSlider.maximumValue = 20000
        freqSlider.value = self.dopplerFrequency
        freqSlider.isContinuous = true
        freqSlider.tintColor = UIColor.green
        freqSlider.addTarget(self, action: #selector(self.onSliderChange), for: UIControl.Event.valueChanged)
        self.view.addSubview(freqSlider)
        
        // Set up Decibel Label
        freqLabel.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2 - 50)
        freqLabel.textAlignment = .center
        freqLabel.text = self.dopplerFrequency.description + "Hz"
        self.view.addSubview(freqLabel)
        
        // Set up Doppler Label
        dopplerLabel.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2 + 50)
        dopplerLabel.textAlignment = .center
        dopplerLabel.text = "No Motion"
        self.view.addSubview(dopplerLabel)
        


        // Start Playing audio and processing microphone data
        audio.startSinewaveProcessing(withFreq: self.dopplerFrequency)
        audio.startMicrophoneProcessing(withFps: 60)
        audio.play()
        
        Timer.scheduledTimer(timeInterval: 0.05, target: self,
            selector: #selector(self.getDopplerData),
            userInfo: nil,
            repeats: true)
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        audio.pause()
        audio.dopplerView = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        audio.dopplerView = true
    }
    

    //callback called when slider moves
    // Update frequency and labels
    @objc func onSliderChange(){
        self.audio.sineFrequency = self.freqSlider.value
        self.dopplerFrequency = self.freqSlider.value
        self.freqLabel.text = self.freqSlider.value.description + " Hz"
        self.audio.dopplerFreq = self.freqSlider.value
    }
    
    @objc
    func getDopplerData(){
        // Zooming in to FFT for viewing purposes. Also shifting values down so they fit on the
        // graph a bit better
        let zoomedData = Array(self.audio.fftData[5400...7700]).map({$0 - 20})
        self.dopplerLabel.text = self.audio.dopplerStatus
        self.graph?.updateGraph(
            data: zoomedData,
            forKey: "microphoneDataDecibels")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
