//
//  AudioViewController.swift
//  common_sense
//
//  Created by Eli Laird on 12/8/20.
//

import UIKit
import MediaPlayer

let AUDIO_BUFFER_SIZE = 131072
let CALIBRATION_FREQUENCY:Float = 1000.0
let MAX_TEST_FREQUENCY:Float = 10000.0
let MIN_TEST_FREQUENCY:Float = 100.0

class DataPipeLine {var dbMax:Float = 0.0; var dbHalf:Float = 0.0; init(m:Float=0, h:Float=0){dbMax=m; dbHalf=h}}

class AudioViewController: UIViewController {

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet weak var calibrateLabel: UILabel!
    @IBOutlet weak var testingFreqLabel: UILabel!
    @IBOutlet weak var waitLabel: UILabel!
    @IBOutlet weak var testCompleteLabel: UILabel!
    @IBOutlet weak var beginTestsButton: UIButton!
    
    weak var delegate: AudioModel!
    
    var canHear:Bool = false
    var buttonPressed:Bool = false
    var pipe = DataPipeLine()  {
        
        didSet {
            DispatchQueue.main.async{
                print("here")
                
                if(self.pipe.dbMax != 0.0){
                    self.dbMax = self.pipe.dbMax
                    self.dbHalf = self.pipe.dbHalf
                    
                    
                    self.audio.pause()
                    print("Finished Calibrating...")
                    self.waitLabel.isHidden = true
                }
            }
        }
    }
    
    
    var dbMax:Float = 0.0
    var dbHalf:Float = 0.0
    
    enum StartingValues:Float {
        case High = 18000.0, Low = 100.0
    }
    
    // setup audio model
    var audio:AudioModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.audio = AudioModel(buffer_size: AUDIO_BUFFER_SIZE, datapipe: &self.pipe)

        //hide buttons initially
        self.toggleHidden(withValue: true)
        self.testCompleteLabel.isHidden = true
        self.beginTestsButton.isHidden = false
        
        self.audio.startSinewaveProcessing(withFreq: CALIBRATION_FREQUENCY)
        self.audio.startMicrophoneProcessing(withFps: 60.0)
        
   
        //self.calibrateMicrophone()
        
        //self.toneTesting()
    }
    
    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)

        audio.pause()
    }
    
    //Button Actions
    @IBAction func yesPressed(_ sender: Any) {
        self.canHear = true
    }
    @IBAction func noPressed(_ sender: Any) {
        self.canHear = false
    }
    
    @IBAction func beginTests(_ sender: Any) {
        self.beginTestsButton.isHidden = true
        self.waitLabel.isHidden = false
        self.audio.calibrate(withFreq: CALIBRATION_FREQUENCY)
        
    }
    
    func toggleHidden(withValue toggle:Bool){
        
        self.queryLabel.isHidden = toggle
        self.yesButton.isHidden = toggle
        self.noButton.isHidden = toggle
        self.testingFreqLabel.isHidden = toggle
        self.waitLabel.isHidden = !toggle
    
    }
    
    //Audio Functions

    
    var testResults:[(frequency: Float, heard: Bool)] = []
    
    func toneTesting(){
        
        var TESTING_HIGH = true
        var TESTING_LOW = true
        var TESTING_FREQUENCY:Float = StartingValues.High.rawValue
        let TEST_INCREMENT:Float = 100.0
        
        self.buttonPressed = false
        
        MPVolumeView.setVolume(0.5)
        self.audio.startSinewaveProcessing(withFreq: TESTING_FREQUENCY)
        
        //test high frequency tones
        while(TESTING_HIGH && (TESTING_FREQUENCY < MAX_TEST_FREQUENCY)){
            
            //show "Can you hear the sound?", "Yes/No" buttons, and testing frequency
            self.toggleHidden(withValue: false)
            self.testingFreqLabel.text = "Testing: \(TESTING_FREQUENCY) Hz"
            
            self.audio.play()
            
            //wait for user to press yes/no button
            while(!self.buttonPressed){/*WAIT FOR USER*/}
            
            self.buttonPressed = false
            
            //check if user could hear frequency, if so increment
            if(self.canHear){
                self.audio.pause()
                TESTING_FREQUENCY += TEST_INCREMENT
                self.audio.startSinewaveProcessing(withFreq: TESTING_FREQUENCY)
            }
            else{
                self.audio.pause()
                TESTING_HIGH = false
            }
            
            self.testResults.append((frequency: TESTING_FREQUENCY, heard: self.canHear))
            
            self.toggleHidden(withValue: true)
            
            //allow noise to dissipate
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){
                //wait for 5 seconds
            }
            
        }
        
        TESTING_FREQUENCY = StartingValues.Low.rawValue
        
        //test low frequency tones
        while(TESTING_LOW && (TESTING_FREQUENCY > MIN_TEST_FREQUENCY)){
            
            //show "Can you hear the sound?", "Yes/No" buttons, and testing frequency
            self.toggleHidden(withValue: false)
            self.testingFreqLabel.text = "Testing: \(TESTING_FREQUENCY) Hz"
            
            self.audio.play()
            
            //wait for user to press yes/no button
            while(!self.buttonPressed){/*WAIT FOR USER*/}
            
            self.buttonPressed = false
            
            //check if user could hear frequency, if so increment
            if(self.canHear){
                self.audio.pause()
                TESTING_FREQUENCY -= TEST_INCREMENT
                self.audio.startSinewaveProcessing(withFreq: TESTING_FREQUENCY)
            }
            else{
                self.audio.pause()
                TESTING_LOW = false
            }
            
            self.testResults.append((frequency: TESTING_FREQUENCY, heard: self.canHear))
            
            self.toggleHidden(withValue: true)
            
            //allow noise to dissipate
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){
                //wait for 5 seconds
            }
        }
        
        self.toggleHidden(withValue: true)
        self.waitLabel.isHidden = true
        self.testCompleteLabel.isHidden = true
        
        print(self.testResults)
        
    }
    
    
    
}
