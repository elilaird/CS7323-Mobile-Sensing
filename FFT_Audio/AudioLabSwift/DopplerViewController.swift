//
//  DopplerViewController.swift
//  AudioLabSwift
//
//  Created by Matthew Lee on 9/27/20.
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit

class DopplerViewController: UIViewController {
    
    let audio = AudioModel(buffer_size: 1024*4)
    let freqSlider = UISlider(frame:CGRect(x: 0, y: 0, width: 300, height: 20))
    let freqLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    let dopplerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    let graphView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    var dopplerFrequency:Float = 1000
    
    lazy var graph:MetalGraph? = {
        return MetalGraph(mainView: self.graphView)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up graph
        self.graphView.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height/6)
        self.graphView.backgroundColor = UIColor(named: "blue")
        print(UIScreen.main.bounds.height)
        
        self.view.addSubview(graphView)
        graph?.addGraph(withName: "microphoneDataDecibels",
                        shouldNormalize: true,
                        numPointsInGraph: 1024*2)
        
        // Set up frequency slider
        freqSlider.center = self.view.center
        freqSlider.minimumValue = 1000
        freqSlider.maximumValue = 15000
        freqSlider.value = self.dopplerFrequency
        freqSlider.isContinuous = true
        freqSlider.tintColor = UIColor.green
        freqSlider.addTarget(self, action: #selector(self.onSliderChange), for: UIControl.Event.valueChanged)
        self.view.addSubview(freqSlider)
        
        // Set up Decibel Label
        freqLabel.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2 - 50)
        freqLabel.textAlignment = .center
        freqLabel.text = self.dopplerFrequency.description + "Decibels"
        self.view.addSubview(freqLabel)
        
        // Set up Doppler Label
        dopplerLabel.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2 + 50)
        dopplerLabel.textAlignment = .center
        dopplerLabel.text = "At Rest"
        self.view.addSubview(dopplerLabel)
        


        
        audio.startSinewaveProcessing(withFreq: self.dopplerFrequency)
        audio.startMicrophoneProcessing(withFps: 30)
        audio.play()
        
        Timer.scheduledTimer(timeInterval: 0.05, target: self,
            selector: #selector(self.updateGraph),
            userInfo: nil,
            repeats: true)
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        audio.pause()
    }
    

    //callback called when value change
    @objc func onSliderChange(){
        self.audio.sineFrequency = self.freqSlider.value
        self.dopplerFrequency = self.freqSlider.value
        self.freqLabel.text = self.freqSlider.value.description + " Decibels"
    }
    
    @objc
    func updateGraph(){
        self.graph?.updateGraph(
            data: self.audio.fftData,
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
