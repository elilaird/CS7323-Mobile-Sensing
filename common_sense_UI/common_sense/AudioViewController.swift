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
let MAX_TEST_FREQUENCY:Float = 20000.0
let MIN_TEST_FREQUENCY:Float = 20.0


class AudioViewController: UIViewController, DataDelegate{
    
    //MARK: Outlets and Variables

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet weak var testingFreqLabel: UILabel!
    @IBOutlet weak var waitLabel: UILabel!
    @IBOutlet weak var beginCalibrationButton: UIButton!
    @IBOutlet weak var toneTestButton: UIButton!
    @IBOutlet weak var testSummary: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var earImage: UIImageView!
    
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
        case High = 5000.0, Low = 600.0
    }
    
    let darkBlue = UIColor(hex: "#0076b4bd")
    let pastelRed = UIColor(red: 255/255, green: 105/255, blue: 97/255, alpha: 1.0)
    let pastelGreen = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
    
    // setup audio model
    var audio:AudioModel!
    
    // setup data interface
    var dataInterface:DataInterface = DataInterface()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let startGrad = UIColor(red: 88/255, green: 102/255, blue: 139/255, alpha: 1.0).cgColor
        gradientLayer.colors = [startGrad, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        DispatchQueue.main.async {
            self.beginCalibrationButton.layer.cornerRadius = 9
            self.toneTestButton.layer.cornerRadius = 9
            self.yesButton.layer.cornerRadius = 9
            self.noButton.layer.cornerRadius = 9
            self.cancelButton.layer.cornerRadius = 9
            
            self.beginCalibrationButton.backgroundColor = self.darkBlue
            self.toneTestButton.backgroundColor = self.darkBlue
            self.yesButton.backgroundColor = self.pastelGreen
            self.noButton.backgroundColor = self.pastelRed
            self.cancelButton.backgroundColor = self.darkBlue
            
            self.beginCalibrationButton.setTitleColor(.white, for: .normal)
            self.toneTestButton.setTitleColor(.white, for: .normal)
            self.yesButton.setTitleColor(.white, for: .normal)
            self.noButton.setTitleColor(.white, for: .normal)
            self.cancelButton.setTitleColor(.white, for: .normal)
            
            if let image = UIImage(named:"ear"){
                self.earImage.image = image
            }
        }
        
        
        self.audio = AudioModel(buffer_size: AUDIO_BUFFER_SIZE)
        
        self.audio.pause()
        
        self.audio.delegate = self
        
        self.testingFreqLabel.adjustsFontSizeToFitWidth = true

        self.audio.startSinewaveProcessing(withFreq: CALIBRATION_FREQUENCY)
        self.audio.startMicrophoneProcessing(withFps: 60.0)
        
    }
    
    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)

        audio.pause()
    }
    
    //MARK: Button Interactions

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
            self.testSummary.isHidden = true
            self.earImage.isHidden = true
        }
        self.audio.calibrate(withFreq: CALIBRATION_FREQUENCY)
    }
    
    @IBAction func cancel(_ sender: Any) {
        DispatchQueue.main.async {
            self.audio.pause()
        }
        //self.audio.pause()
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    
    func segueToResults(){
        DispatchQueue.main.async {
            self.audio.pause()
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "AudioResults")
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
     
    
    //MARK: Utility Functions
    
    func toggleHidden(withValue toggle:Bool){
        DispatchQueue.main.async {
            self.queryLabel.isHidden = toggle
            self.yesButton.isHidden = toggle
            self.noButton.isHidden = toggle
            self.testingFreqLabel.isHidden = toggle
            self.waitLabel.isHidden = !toggle
        }
    }
    
    func getFormattedFrequency(with freq:Float) -> String{
        let formatter = MeasurementFormatter()
        let hertz = Measurement(value: Double(freq), unit: UnitFrequency.hertz)
        return formatter.string(from: hertz)
    }
    
    //MARK: Audio Functions
    
    func toneTesting(){
        DispatchQueue.global(qos: .userInteractive).async {
            
            
            var upperBound:Float
            var lowerBound:Float
       
            var maxVolumeUpperBound:Float
            var maxVolumeLowerBound:Float
            
            
            var start:Float = StartingValues.High.rawValue
            var end:Float = MAX_TEST_FREQUENCY
            var inc:Float = 1000.0
            
            while((end - start) > 100 && (start > 3000.0)){
                end = self.findUpperBound(withStarting: start, andStopping: end, andStep: inc)
                print("Found upper bound of \(end)")
                print("start \(start)")
                start = end - inc
                inc = inc / 2
        
            }
            
            upperBound = end - inc

            
            start = StartingValues.Low.rawValue
            end = MIN_TEST_FREQUENCY
            inc = 200
            while((start - end) > 100 && (start < StartingValues.High.rawValue)){
                end = self.findLowerBound(withStarting: start, andStopping: end, andStep: inc)
                print("Found upper bound of \(end)")
                print("start \(start)")
                start = end + inc
                inc = inc / 2
                
            }
            lowerBound = end + inc
            

            DispatchQueue.main.async {
                MPVolumeView.setVolume(1.0)
            }
            
      
            
            maxVolumeUpperBound = self.findUpperBound(withStarting: upperBound, andStopping: MAX_TEST_FREQUENCY, andStep: 100.0)
            print("Max volume upper bound of \(maxVolumeUpperBound)")
            maxVolumeLowerBound = self.findLowerBound(withStarting: lowerBound, andStopping: MIN_TEST_FREQUENCY, andStep: 50.0)
            print("Max volume lower bound of \(maxVolumeLowerBound)")

            DispatchQueue.main.async {
                self.waitLabel.isHidden = true
            }
            
            self.dataInterface.saveAudioData(lowFrequencyAtdB: lowerBound, highFrequencyAtdB: end, dB: self.dbHalf, lowFrequencyAtMaxdB: maxVolumeLowerBound, highFrequencyAtMaxdB: maxVolumeUpperBound, maxdB: self.dbMax)

            self.segueToResults()
        }
    }
   


    var testResults:[(frequency: Float, heard: Bool)] = []
    
    //MARK: Find upper bound
    func findUpperBound(withStarting frequency:Float, andStopping endFreq:Float, andStep increment:Float) -> (Float) {
        var TESTING_HIGH = true
        var TESTING_FREQUENCY:Float = frequency
        let TEST_INCREMENT:Float = increment
        
        self.buttonPressed = false
        
        let outerGroup = DispatchGroup()
        outerGroup.enter()
        DispatchQueue.global(qos: .userInteractive).async {
            
            
            self.audio.startSinewaveProcessing(withFreq: TESTING_FREQUENCY)
            
            while(TESTING_HIGH && (TESTING_FREQUENCY <= endFreq)){

                //show "Can you hear the sound?", "Yes/No" buttons, and testing frequency
                DispatchQueue.main.async {
                    self.toggleHidden(withValue: false)
                    self.testingFreqLabel.text = "Frequency: " + self.getFormattedFrequency(with: TESTING_FREQUENCY)
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
    func findLowerBound(withStarting frequency:Float, andStopping end:Float, andStep increment:Float) -> (Float) {
        var TESTING_LOW = true
        var TESTING_FREQUENCY:Float = frequency
        let TEST_INCREMENT:Float = increment
        
        self.buttonPressed = false
        
        let outerGroup = DispatchGroup()
        outerGroup.enter()
        DispatchQueue.global(qos: .userInteractive).async {
            
            
            self.audio.startSinewaveProcessing(withFreq: TESTING_FREQUENCY)
            
            while(TESTING_LOW && (TESTING_FREQUENCY >= MIN_TEST_FREQUENCY)){

                //show "Can you hear the sound?", "Yes/No" buttons, and testing frequency
                DispatchQueue.main.async {
                    self.toggleHidden(withValue: false)
                    self.testingFreqLabel.text = "Frequency: " + self.getFormattedFrequency(with: TESTING_FREQUENCY)
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
