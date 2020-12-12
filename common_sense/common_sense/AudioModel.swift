//
//  AudioModel.swift
//  AudioLabSwift
//
//  Created by Eric Larson 
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import Foundation
import Accelerate
import MediaPlayer

protocol DataDelegate: AudioViewController {
    func foundDbValues(withMax max:Float, andHalf half:Float)
}

class AudioModel {
    
    // MARK: Properties
    private var BUFFER_SIZE:Int
    private var phase:Float = 0.0
    private var phaseIncrement:Float = 0.0
    private var sineWaveRepeatMax:Float = Float(2*Double.pi)
    
    weak var delegate:DataDelegate?
 
    var dbMax:Float = 0.0
    var dbHalf:Float = 0.0
    
    let DB_ERROR:Float = 13.0
    let DB_HALF_OFFSET:Float = 10.0
    
    // thse properties are for interfaceing with the API
    // the user can access these arrays at any time and plot them if they like
    var timeData:[Float]
    var fftData:[Float]
    var fftDecibels:[Float]
    var dataEqualizer:[Float]
    
    var sineFrequency:Float = 0.0 {
        didSet{
            self.audioManager?.sineFrequency = sineFrequency
        }
    }
    
    
    // MARK: Public Methods
    init(buffer_size:Int) {
        BUFFER_SIZE = buffer_size
        // anything not lazily instantiated should be allocated here
        timeData = Array.init(repeating: 0.0, count: BUFFER_SIZE)
        fftData = Array.init(repeating: 0.0, count: BUFFER_SIZE/2)
        fftDecibels = Array.init(repeating: 0.0, count: BUFFER_SIZE/2)
        dataEqualizer = Array.init(repeating: 0.0, count: 20)
    }
    
    // public function for starting processing of microphone data
    func startMicrophoneProcessing(withFps:Double){
        // setup the microphone to copy to circualr buffer
        self.audioManager?.inputBlock = self.handleMicrophone

        // repeat this fps times per second using the timer class
        //   every time this is called, we update the arrays "timeData" and "fftData"
        Timer.scheduledTimer(timeInterval: 1.0/withFps, target: self,
                            selector: #selector(self.runEveryInterval),
                            userInfo: nil,
                            repeats: true)

    }
    
    
    func startSinewaveProcessing(withFreq:Float=1000){
        sineFrequency = withFreq
        self.audioManager?.setOutputBlockToPlaySineWave(sineFrequency) // c for loop
    }
    
    
    // You must call this when you want the audio to start being handled by our model
    func play(){
        print("play")
        self.audioManager?.play()
    }

    func pause(){
        print("pause")
        self.audioManager?.pause()
    }
    
    
    func calibrate(withFreq freq:Float=1000){
        
        print("Calibrating...")
        
        //set volume to max
        DispatchQueue.main.async {
            MPVolumeView.setVolume(1.0)
        }

        self.play()
        
        let index:Int = (Int(freq) * BUFFER_SIZE) / 44100

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.dbMax = self.fftData[index] + self.DB_ERROR
            self.dbHalf = self.dbMax - self.DB_HALF_OFFSET
            print("Db Max: \(self.dbMax) ")
            self.delegate?.foundDbValues(withMax: self.dbMax, andHalf: self.dbHalf)
        }
    }
    
    
    //==========================================
    // MARK: Private Properties
    private lazy var audioManager:Novocaine? = {
        return Novocaine.audioManager()
    }()
    
    private lazy var fftHelper:FFTHelper? = {
        return FFTHelper.init(fftSize: Int32(BUFFER_SIZE))
    }()
    
    
    private lazy var inputBuffer:CircularBuffer? = {
        return CircularBuffer.init(numChannels: Int64(self.audioManager!.numInputChannels),
                                   andBufferSize: Int64(BUFFER_SIZE))
    }()
    
    

    //==========================================
    // MARK: Model Callback Methods
    @objc
    private func runEveryInterval(){
        if inputBuffer != nil {
            // copy time data to swift array
            self.inputBuffer!.fetchFreshData(&timeData,
                                             withNumSamples: Int64(BUFFER_SIZE))
            
            // now take FFT
            fftHelper!.performForwardFFT(withData: &timeData,
                                         andCopydBMagnitudeToBuffer: &fftData)
            
            
        }
    }
    

    
    //==========================================
    // MARK: Audiocard Callbacks
    // in obj-C it was (^InputBlock)(float *data, UInt32 numFrames, UInt32 numChannels)
    // and in swift this translates to:
    private func handleMicrophone (data:Optional<UnsafeMutablePointer<Float>>, numFrames:UInt32, numChannels: UInt32) {
        // copy samples from the microphone into circular buffer
        self.inputBuffer?.addNewFloatData(data, withNumSamples: Int64(numFrames))
    }
    

    
}
