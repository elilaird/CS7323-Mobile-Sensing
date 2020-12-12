//
//  AudioViewController.swift
//  common_sense
//
//  Created by Eli Laird on 12/8/20.
//

import UIKit
import MediaPlayer

let AUDIO_BUFFER_SIZE = 131072
let CALIBRATION_FREQUENCY:Float = 3000.0
let MAX_TEST_FREQUENCY:Float = 18000.0
let MIN_TEST_FREQUENCY:Float = 50.0


class AudioViewController: UIViewController, DataDelegate{
    
    //MARK: Outlets and Variables

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet weak var testingFreqLabel: UILabel!
    @IBOutlet weak var waitLabel: UILabel!
    @IBOutlet weak var testCompleteLabel: UILabel!
    @IBOutlet weak var beginCalibrationButton: UIButton!
    @IBOutlet weak var toneTestButton: UIButton!
    
    weak var delegate: AudioModel!
    
    var canHear:Bool = false
    var buttonPressed:Bool = false
    var calibrating:Bool = true {
        didSet {
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.toneTestButton.isHidden = false
                self.waitLabel.isHidden = true
                MPVolumeView.setVolume(0.5)
                group.leave()
            }
            
            group.notify(queue: .main){
                print("done calibrating")
            }
            
        }
    }
    
    
    var dbMax:Float = 0.0
    var dbHalf:Float = 0.0
    
    enum StartingValues:Float {
        case High = 15000.0, Low = 1000.0
    }
    
    // setup audio model
    var audio:AudioModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.audio = AudioModel(buffer_size: AUDIO_BUFFER_SIZE)
        
        self.audio.delegate = self
        
        self.testingFreqLabel.adjustsFontSizeToFitWidth = true

        self.audio.startSinewaveProcessing(withFreq: CALIBRATION_FREQUENCY)
        self.audio.startMicrophoneProcessing(withFps: 60.0)
        
    }
    
    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)

        audio.pause()
    }
    
    //Button Actions
    @IBAction func yesPressed(_ sender: Any) {
        print("yes pressed")
        self.canHear = true
        self.buttonPressed = true
    }
    
    @IBAction func noPressed(_ sender: Any) {
        print("no pressed")
        self.canHear = false
        self.buttonPressed = true
    }
    @IBAction func startTests(_ sender: Any) {
        DispatchQueue.main.async {
            self.toneTestButton.isHidden = true
            self.toggleHidden(withValue: false)
        }
        self.toneTesting()
    }
    
    @IBAction func beginCalibration(_ sender: Any) {
        DispatchQueue.main.async {
            self.beginCalibrationButton.isHidden = true
            self.waitLabel.isHidden = false
        }
        self.audio.calibrate(withFreq: CALIBRATION_FREQUENCY)
    }
    
    func toggleHidden(withValue toggle:Bool){
        DispatchQueue.main.async {
            self.queryLabel.isHidden = toggle
            self.yesButton.isHidden = toggle
            self.noButton.isHidden = toggle
            self.testingFreqLabel.isHidden = toggle
            self.waitLabel.isHidden = !toggle
        }
    }
    
    
    //MARK: Audio Functions
    
    func toneTesting(){
        DispatchQueue.global(qos: .userInteractive).async {
            
            DispatchQueue.main.async {
                self.testCompleteLabel.isHidden = true
            }
            
            var upperBound:Float
            var lowerBound:Float
            
            upperBound = self.findUpperBound(withStarting: StartingValues.High.rawValue, andStep: 500.0)
            print("Found upper bound of \(upperBound)")
            upperBound = self.findUpperBound(withStarting: upperBound, andStep: 50.0)
            print("Found upper bound of \(upperBound)")

            lowerBound = self.findLowerBound(withStarting: StartingValues.Low.rawValue, andStep: 200.0)
            print("Found lower bound of \(lowerBound)")
            lowerBound = self.findLowerBound(withStarting: lowerBound, andStep: 50.0)
            print("Found lower bound of \(lowerBound)")
            
            //find the bounds with max volume
            var maxVolumeUpperBound:Float
            var maxVolumeLowerBound:Float
            
            DispatchQueue.main.async {
                MPVolumeView.setVolume(1.0)
            }
            
            maxVolumeUpperBound = self.findUpperBound(withStarting: upperBound, andStep: 10.0)
            print("Max volume upper bound of \(maxVolumeUpperBound)")
            maxVolumeLowerBound = self.findLowerBound(withStarting: lowerBound, andStep: 10.0)
            print("Max volume lower bound of \(maxVolumeLowerBound)")
            
            DispatchQueue.main.async {
                self.testCompleteLabel.isHidden = false
                self.waitLabel.isHidden = true
            }

        }
    }
   


    var testResults:[(frequency: Float, heard: Bool)] = []
    
    func findUpperBound(withStarting frequency:Float, andStep increment:Float) -> (Float) {
        var TESTING_HIGH = true
        var TESTING_FREQUENCY:Float = frequency
        let TEST_INCREMENT:Float = increment
        
        self.buttonPressed = false
        
        let outerGroup = DispatchGroup()
        outerGroup.enter()
        DispatchQueue.global(qos: .userInteractive).async {
            
            
            self.audio.startSinewaveProcessing(withFreq: TESTING_FREQUENCY)
            
            //MARK: Find upper bound
            while(TESTING_HIGH && (TESTING_FREQUENCY <= MAX_TEST_FREQUENCY)){

                //show "Can you hear the sound?", "Yes/No" buttons, and testing frequency
                DispatchQueue.main.async {
                    self.toggleHidden(withValue: false)
                    let formatter = MeasurementFormatter()
                    let hertz = Measurement(value: Double(TESTING_FREQUENCY), unit: UnitFrequency.hertz)
                    self.testingFreqLabel.text = "Frequency: \(formatter.string(from: hertz))"
                }

                print("Testing: \(TESTING_FREQUENCY) Hz")
    
                self.audio.play()

                var group = DispatchGroup()
                group.enter()
                DispatchQueue.global(qos: .background).async {
                    //wait for user to press yes/no button
                    while(!self.buttonPressed){/*WAIT FOR USER*/}
                    group.leave()
                }
                group.wait()


                self.buttonPressed = false
    
                //check if user could hear frequency, if so increment
                if(self.canHear){
                    self.audio.pause()
                    self.testResults.append((frequency: TESTING_FREQUENCY, heard: self.canHear))
                    TESTING_FREQUENCY += TEST_INCREMENT
                    self.audio.startSinewaveProcessing(withFreq: TESTING_FREQUENCY)
                } else{
                    self.audio.pause()
                    self.testResults.append((frequency: TESTING_FREQUENCY, heard: self.canHear))
                    TESTING_HIGH = false
                }
    
                DispatchQueue.main.async {
                    self.toggleHidden(withValue: true)
                }
                
                //allow noise to dissipate
                group = DispatchGroup()
                group.enter()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                    //wait for 3 seconds
                    group.leave()
                }
                group.wait()
            
            }
            outerGroup.leave()
        }
        outerGroup.wait()
        return testResults.last!.frequency
    }
    
    //MARK: Find lower bound
    func findLowerBound(withStarting frequency:Float, andStep increment:Float) -> (Float) {
        var TESTING_LOW = true
        var TESTING_FREQUENCY:Float = frequency
        let TEST_INCREMENT:Float = increment
        
        self.buttonPressed = false
        
        let outerGroup = DispatchGroup()
        outerGroup.enter()
        DispatchQueue.global(qos: .userInteractive).async {
            
            
            self.audio.startSinewaveProcessing(withFreq: TESTING_FREQUENCY)
            
            //MARK: Find upper bound
            while(TESTING_LOW && (TESTING_FREQUENCY >= MIN_TEST_FREQUENCY)){

                //show "Can you hear the sound?", "Yes/No" buttons, and testing frequency
                DispatchQueue.main.async {
                    self.toggleHidden(withValue: false)
                    let formatter = MeasurementFormatter()
                    let hertz = Measurement(value: Double(TESTING_FREQUENCY), unit: UnitFrequency.hertz)
                    self.testingFreqLabel.text = "Frequency: \(formatter.string(from: hertz))"
                }

                print("Frequency: \(TESTING_FREQUENCY) Hz")
    
                self.audio.play()

                var group = DispatchGroup()
                group.enter()
                DispatchQueue.global(qos: .background).async {
                    //wait for user to press yes/no button
                    while(!self.buttonPressed){/*WAIT FOR USER*/}
                    group.leave()
                }
                group.wait()


                self.buttonPressed = false
    
                //check if user could hear frequency, if so increment
                if(self.canHear){
                    self.audio.pause()
                    self.testResults.append((frequency: TESTING_FREQUENCY, heard: self.canHear))
                    TESTING_FREQUENCY -= TEST_INCREMENT
                    self.audio.startSinewaveProcessing(withFreq: TESTING_FREQUENCY)
                } else{
                    self.audio.pause()
                    self.testResults.append((frequency: TESTING_FREQUENCY, heard: self.canHear))
                    TESTING_LOW = false
                }

                DispatchQueue.main.async {
                    self.toggleHidden(withValue: true)
                }
                
                //allow noise to dissipate
                group = DispatchGroup()
                group.enter()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                    //wait for 3 seconds
                    group.leave()
                }
                group.wait()
            
            }
            outerGroup.leave()
        }
        outerGroup.wait()
        return testResults.last!.frequency
    }
    
   

    
    
}