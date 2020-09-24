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
    let fftData:[Float]
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
//        getPeakFrequencies(withFl: nil, withFh: nil)

        let absences = [0,1,2,3,4,5,6]
        let test = absences[2...5]
        print("*****************Test: \(test)")
        
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
     
     With the low and high cuttoff, we can just threshold for Doppler shifts.  Basically make a
     decision when the max value in the returned array is above/below a threshold
    */
    func getPeakFrequencies(withFl:Float?, withFh:Float?) -> Array<Float>{
        
        var fftScope = ArraySlice(self.fftData)
        
        if (withFl != nil || withFh != nil){
            fftScope = splitFFT(withFl: withFl, withFh: withFh)
        }
        
        return [1.0, 2.0]
    }
    
    
    
    // MARK: Private Methods
    
    private struct Peak {
        /*
            Properties
                f2: frequency where peak occured
                m1: magnitude of the value to the left of the peak
                m2: magnitude of the value of the peak
                m3: magnitude of the value to the right of the peak
         */
        var f2:Float
        var m1:Float
        var m2:Float
        var m3:Float
    }
    
    // finds the peaks of an input signal
    private func findPeaks(samples:ArraySlice<Float>) -> Array<Peak>{
        
        return [Peak(f2: 55, m1: 10, m2: 12, m3: 11)]
    }
    
    // splits an fft array from low and high frequencies (note: returns a view for memory efficiency)
    private func splitFFT(withFl:Float?, withFh:Float?) -> ArraySlice<Float>{
        
        // for simplicity in other functions, just returning a view of fftData
        if withFl == nil && withFh == nil{
            return self.fftData[0...]
        }
        
        var fl = 0
        var fh = self.nFFTFrames - 1
        
        if withFl != nil{
            fl = getIndexForFrequency(withFrequency: withFl!, roundUp: false)
        }
        
        if withFh != nil{
            fh = getIndexForFrequency(withFrequency: withFh!, roundUp: true)
        }
        
        return self.fftData[fl...fh]
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
    private func peakInterpolation(p:Peak) ->Float{
        // assumes that we are using the points to the left and right of the found max (m2)
        let deltaF = self.hertzBetweenSamples*2
        
        return p.f2 + ((p.m1-p.m3)/(p.m3-2*p.m2+p.m1))*(deltaF/2)
    }
    
}
