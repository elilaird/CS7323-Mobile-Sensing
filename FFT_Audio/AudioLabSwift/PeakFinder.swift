//
//  PeakFinder.swift
//  AudioLabSwift
//
//  Created by Clay Harper on 9/23/20.
//  Copyright © 2020 Clay Harper. All rights reserved.
//

import Foundation
import Accelerate

class PeakFinder {
    
    // MARK: Properties
    let BUFFER_SIZE:Int
    var fftData:[Float]
    let Fs:Float
    
    // computed property for fft length
    var nFFTFrames: Int {
        get {
            return fftData.count
        }
    }
    
    // computed property for number of hertz between samples in the fft
    var hertzBetweenSamples: Float {
        get {
            return Fs/Float(nFFTFrames)
        }
    }
    
    
    // MARK: Public Methods
    
    // Initialize class instance
    init(buffer_size:Int, fftArray:Array<Float>, samplingFrequency:Float) {
        BUFFER_SIZE = buffer_size
        fftData = fftArray
        Fs = samplingFrequency
        getPeakFrequencies(withFl: nil, withFh: nil)
    }
    
    /*
     Get array of peak frequencies in an fft. Optional low and high cutoff frequencies
     (fl and fh) for doppler
     
     Examples:
    
         // get peaks over entire fft
         getPeakFrequencies(withFl: nil, withFh: nil)
     
        // get peaks from low frequency (500Hz) onwards (inclusive)
        getPeakFrequencies(withFl: 500, withFh: nil)
     
        // get peaks up to high frequency (500Hz) (inclusive)
        getPeakFrequencies(withFl: nil, withFh: 500)
     
        // get peaks between low frequency (500Hz) and high frequency (1KHz) (inclusive on both)
        getPeakFrequencies(withFl: 500, withFh: 1000)
    */
    func getPeakFrequencies(withFl:Float?, withFh:Float?) -> Array<Float>{
        
        var fftScope = fftData
        
        if (withFl != nil || withFh != nil){
            fftScope = splitFFT(withFl: withFl, withFh: withFh)
        }
        
        return [1.0, 2.0]
    }
    
    
    
    // MARK: Private Methods
    
    // finds the peaks of an input signal 
    private func findPeaks(infftScope:Array<Float>) -> Array<Float>{
        return [1.0, 1.2]
    }
    
    // splits an fft array from low and high frequencies
    private func splitFFT(withFl:Float?, withFh:Float?) -> Array<Float>{
        
        
        return [1.0, 2.0]
    }
    
    // calculates the index position in an fft array for a freqency.
    private func getIndexForFrequency(withFrequency:Float, roundUp:Bool) -> Int{
        let floatIndex = withFrequency/self.hertzBetweenSamples
        
        // if the frequency is smaller than the hertzBetweenSamples
        if floatIndex < 0 {
            return 0
        }
        
        // if the index is out of bounds of the number of fft frames, return max frequency
        if floatIndex > Float(nFFTFrames) {
            return nFFTFrames - 1
        }
        
        // Round up for high frequency, down for low frequency (to include both)
        if roundUp{
            return Int(floatIndex.rounded(.up))
        }
        
        return Int(floatIndex.rounded(.down))
    }
    
    
    
    
    
    
    // implement later if time:
    //    func get
    
}
