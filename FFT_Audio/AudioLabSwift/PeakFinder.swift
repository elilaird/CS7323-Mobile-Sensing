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
    var fftData:[Float]
    var Fs:Float
    
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
    init(fftArray:Array<Float>, samplingFrequency:Float) {
        fftData = fftArray
        Fs = samplingFrequency
    }
    
    // Setters for changing fftData and Fs (although shouldn't need for this lab)
    func setFFTData(fftArray:Array<Float>){
        self.fftData = fftArray
    }
    
    func setFs(samplingFrequency:Float){
        self.Fs = samplingFrequency
    }
    
    struct Peak {
        /*
            Properties
                f2: frequency where peak occured
                m1: magnitude of the value to the left of the peak
                m2: magnitude of the value of the peak
                m3: magnitude of the value to the right of the peak
         */
        var f2:Float?
        var m1:Float?
        var m2:Float?
        var m3:Float?
    }
    

    /*
     Get array of peak frequencies in an fft. Optional low and high cutoff frequencies
     (fl and fh) for doppler
     
     Examples:
    
         // get peaks over entire fft
        getPeaks(withFl: nil, withFh: nil)
     
        // get peaks from low frequency (500Hz) onwards (inclusive)
        getPeaks(withFl: 500, withFh: nil)
     
        // get peaks up to high frequency (500Hz) (inclusive)
        getPeaks(withFl: nil, withFh: 500)
     
        // get peaks between low frequency (500Hz) and high frequency (1KHz) (inclusive on both)
        getPeaks(withFl: 500, withFh: 1000)
     
     With the low and high cuttoff, we can just threshold for Doppler shifts.  Basically make a
     decision when the max value in the returned array is above/below a threshold.
    */
    func getPeaks(withFl:Float?, withFh:Float?, expectedHzApart:Float) -> Array<Peak>{
        
        var fftScope = ArraySlice(self.fftData)
        
        // Make a slice of the fft
        if (withFl != nil || withFh != nil){
            fftScope = splitFFT(withFl: withFl, withFh: withFh)
        }
        
        // Get the peaks in the time series
        var peakIndexesInScope: Array<Int>
//        let maxWindowSize = self.hertzBetweenSamples * 2
//        var windowSize = Int(maxWindowSize.rounded(.down))
        
        let maxWindowSize = (expectedHzApart/self.hertzBetweenSamples)*2 - 1
        var windowSize = Int(maxWindowSize.rounded(.down))
        
        // Make sure windowSize is odd (so peaks fall right in the middle)
        if windowSize % 2 == 0 {
            windowSize = windowSize - 1
        }
        
        peakIndexesInScope = self.findPeaksUtil(samples: fftScope, windowSize: windowSize)
        
        // Convert peakIndexesInScope to indexes of the FFT signal
        var lowFreq: Float = 0
        if withFl != nil {
            lowFreq = withFl!
        }
        let scopeOffset = self.getIndexForFrequency(withFrequency: lowFreq, roundUp: false)
        
        // Add offset to each index
        peakIndexesInScope = peakIndexesInScope.map({ $0 + scopeOffset }) // This should work, but want to test when we play a known sine wave

        // Make peaks array
        var peaks: Array<Peak> = []
        
        for index in peakIndexesInScope{
            peaks.append(Peak(f2: self.getFrequency(withIndex: index), m1: self.fftData[index-1], m2: self.fftData[index],
                              m3: self.fftData[index+1]))
        }
        
        return peaks
    }
    
    
    
    // MARK: Private Methods

    
    // Finds the indexes where peaks occur with a given window size
    private func findPeaksUtil(samples:ArraySlice<Float>, windowSize:Int) -> Array<Int>{
        
        let stride = 1
        
        // Output array of index of peaks (only if peak happens in the middle)
        // Note: these are the indexes relative to the provided samples slice!
        var peakIndexesInSample: Array<Int> = []
        
        /*
            How windowSize should be computed before being passed in:
                    
                 let maxWindowSize = self.hertzBetweenSamples * 2
                 var windowSize = Int(maxWindowSize.rounded(.down))
                 
                 // Make sure windowSize is odd (so peaks fall right in the middle)
                 if windowSize % 2 == 0 {
                     windowSize = windowSize - 1
                 }
         */
    
        // If our window size is too large or an even number, return empty array (no peaks)
        if ((windowSize > samples.count) || windowSize%2 == 0){
            return peakIndexesInSample
        }
        
        // Edge cases (peaks fall at the beginning or end of samples (handing with 0 padding)
        let sidesPadding = windowSize/2
        let paddedSamples = Array(samples).pad(left: sidesPadding, right: sidesPadding)
        let nWindowPositions = paddedSamples.count - windowSize + 1
        
        // Iterate over samples to find peaks within the window
        for windowIndex in 0...nWindowPositions-1{
            let window = paddedSamples[windowIndex*stride...(windowIndex*stride)+windowSize-1]
            
            // Get max value in window and check that it is the middle index
            var maxOccurredIndex: UInt = 0
            var maxValue: Float = 0
            vDSP_maxvi(Array(window), vDSP_Stride(1), &maxValue, &maxOccurredIndex, vDSP_Length(window.count))
            
            // Only add the peak if it occured in the middle of the window
            if maxOccurredIndex == windowSize/2{
                // Since our window is centered, windowIndex is the same as where the peak occured in samples
                peakIndexesInSample.append(Int(windowIndex))
            }
        }
        return peakIndexesInSample
    }
    
    // Splits an fft array from low and high frequencies (note: returns a view for memory efficiency)
    private func splitFFT(withFl:Float?, withFh:Float?) -> ArraySlice<Float>{
        
        // For simplicity in other functions, just returning a view of fftData
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
    
    // Calculates the frequency for a given index
    private func getFrequency(withIndex:Int) -> Float {
        // assumes we are using the sampling frequency and NFFTFrames for this class instance
        return Float(withIndex)*self.hertzBetweenSamples
    }
    
    // Calculates the index position in an fft array for a freqency.
    private func getIndexForFrequency(withFrequency:Float, roundUp:Bool) -> Int{
        let floatIndex = withFrequency/self.hertzBetweenSamples
        
        // If the frequency is smaller than the hertzBetweenSamples
        if floatIndex < 0 {
            return 0
        }
        
        // If the index is out of bounds of the number of fft frames, return max frequency
        if floatIndex > Float(nFFTFrames) {
            // should we make this raise an error?
            return nFFTFrames - 1
        }
        
        // Round up for high frequency, down for low frequency (to include both)
        if roundUp{
            return Int(floatIndex.rounded(.up))
        }
        
        return Int(floatIndex.rounded(.down))
    }
    
    // Implement later if time:
    private func peakInterpolation(p:Peak) ->Float{
        // Assumes that we are using the points to the left and right of the found max (m2)
        let deltaF = self.hertzBetweenSamples*2
        let fraction = (p.m1! - p.m3!)/(p.m3! - 2*p.m2! + p.m1!)
        
        return p.f2! + fraction * (deltaF/2)
    }
    
    private func filterPeaks50HertzApart(peaks: Array<Peak>) -> Array<Peak>{
        return [Peak(f2: nil, m1: nil, m2: nil, m3: nil)]
    }
    
    private func sortPeaksDescendingMagnitude(peaks: Array<Peak>, topK:Int?) -> Array<Peak>{
        // Sort peaks
        let sortedPeaks = peaks.sorted { (lhs, rhs) in return lhs.m2! > rhs.m2! } // descending order
        
        var kElements = sortedPeaks.count-1
        if topK != nil {
            kElements = topK!
        }
        
        // Return the top K frequency peaks
        return Array(sortedPeaks[...kElements])
    }
    
}

// Issue finding max value we thought was in window
enum NotInWindowError: Error {
    case runtimeError(String)
}

// Zero padding to avoid edge cases for peaks
// taken from Luca Angeletti's answer here: https://stackoverflow.com/questions/38777401/pad-an-array-with-0s-swift
// modified for float arrays and newer swift version.
extension Array where Element == Float {
    func pad(left: Int, right: Int) -> [Float] {
        let leftSide = Array.init(repeating: 0.0, count: left)
        let rightSide = Array.init(repeating: 0.0, count: right)
        return leftSide + self + rightSide
    }
}
