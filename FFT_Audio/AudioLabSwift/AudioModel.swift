//
//  AudioModel.swift
//  AudioLabSwift
//
//  Created by Eric Larson 
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import Foundation
import Accelerate

class AudioModel {
    
    // MARK: Properties
    private var BUFFER_SIZE:Int
    private var phase:Float = 0.0
    private var phaseIncrement:Float = 0.0
    private var sineWaveRepeatMax:Float = Float(2*Double.pi)
    private var peakFinder:PeakFinder
    
    // thse properties are for interfaceing with the API
    // the user can access these arrays at any time and plot them if they like
    var timeData:[Float]
    var fftData:[Float]
    
    var sineFrequency:Float = 0.0 {
        didSet{
            self.audioManager?.sineFrequency = sineFrequency
        }
    }
    
    
    // MARK: Public Methods
    init(buffer_size:Int) {
        BUFFER_SIZE = buffer_size
        // anything not lazily instatntiated should be allocated here
        timeData = Array.init(repeating: 0.0, count: BUFFER_SIZE)
        fftData = Array.init(repeating: 0.0, count: BUFFER_SIZE/2)
        peakFinder = PeakFinder(fftArray: fftData, samplingFrequency: 44100.0)
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
    
    func startSongMicrophoneProcessing(withFps:Double){
        // allow listening to the song
        self.audioManager?.outputBlock = self.handleSpeakerQueryWithAudioFile
        
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
    // MARK: Private Methods
    private lazy var fileReader:AudioFileReader? = {
        if let url = Bundle.main.url (forResource: "satisfaction", withExtension: "mp3"){
            var tmpFileReader:AudioFileReader? = AudioFileReader.init(audioFileURL: url, samplingRate: Float(audioManager!.samplingRate), numChannels: audioManager!.numOutputChannels)
            
            tmpFileReader!.currentTime = 0.0
            print("Audio file success loaded \(url)")
            return tmpFileReader
        }else{
            print("Error loading file")
            return nil
        }
    }()
    
    
    // NONE for this model
    
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

            
            peakFinder.setFFTData(fftArray: fftData)
            let peaks = peakFinder.getPeaks(withFl: nil, withFh: nil, expectedHzApart: 50)
            
//            for i in 0...fftData.count-1 {
//                print("\(fftData[i])-")
//            }
            if peaks.count > 1 {
                let sortedPeaks = peakFinder.sortPeaksDescendingMagnitude(peaks: peaks, topK: nil)
                let loudestFreq = sortedPeaks[0]
                let secondLoudestFreq = sortedPeaks[1]
                let minFreq = sortedPeaks[sortedPeaks.count-1]
                
                print("Loudest Freq: \((loudestFreq.f2)!), Mag1: \((loudestFreq.m2)!), Second Loudest Freq: \((secondLoudestFreq.f2)!), MinFreq: \((minFreq.f2)!), MinMag: \((minFreq.m2)!)")
            }
            
            
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
    
    private func handleSpeakerQueryWithAudioFile(data:Optional<UnsafeMutablePointer<Float>>, numFrames:UInt32, numChannels:UInt32){
        if let file = self.fileReader{
            file.retrieveFreshAudio(data, numFrames: numFrames, numChannels: numChannels)
            self.inputBuffer?.addNewFloatData(data, withNumSamples: Int64(numFrames))
        }
    }
    
}
