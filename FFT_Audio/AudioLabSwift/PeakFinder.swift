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
        

        let absences = [0.0,1.0,2,3,4,5,6]
        var dataEqualizer = Array.init(repeating: 0.0, count: 20)
        let test = absences[2...5]
        
        
//        vDSP_vswmaxD(absences, 2, &dataEqualizer, 1, 3, 2)
        
        
//        var tester = Array.init(repeating: 0.0, count: 20)
//        let nBatches = 20
//        let stride = Int(BUFFER_SIZE/40)
//
//        for i in 0...nBatches-1{
//
//            let batchMax = fftData[i*stride...(i+1)*stride].max()
//            dataEqualizer[i] = batchMax!
//        }
        
        
        print("*****************Test: \(dataEqualizer)")
        
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
    
    // Finds the peaks of an input signal
    private func findPeaks(samples:ArraySlice<Float>) throws -> Array<Peak> {
        
        // Get max magnitudes in the samples array (since we know the output, we know which windows
        // correspond to which max values...important for determining the peak index
        
        // Might need to adjust based on performance (probably still want smaller than/equal to window size...starting wih 0% overlap for simplicity)
        let stride = 5
        let windowSize = 5
        let nWindowPositions = (samples.count - windowSize + 1)/stride
        
        // Output array for peak magnitudes
        var peakMagnitudes: Array<Float> = Array.init(repeating: 0.0, count: nWindowPositions)
        var peakMagnitudesIndexes = Array.init(repeating: 0, count: nWindowPositions)
        var peaks: Array<Peak> = []
        
        // Convert samples into a float array
        let arrSamples: Array<Float> = Array(samples)
        
        // Calculate peak magnitudes
        vDSP_vswmax(arrSamples, vDSP_Stride(stride), &peakMagnitudes, vDSP_Stride(1), vDSP_Length(nWindowPositions), vDSP_Length(windowSize))
        
        // Find the indexes of the peaks in the samples slice and make a peak
        for (i, peakMag) in peakMagnitudes.enumerated(){
            // make slice of array
            let batch = samples[i*windowSize...(i+1)*windowSize-1] // assuming no overlap
            
            // get the index where the peak occurs
            let indexWherePeakOccurredInBatch = batch.firstIndex(of: peakMag)
            
            if indexWherePeakOccurredInBatch == nil {
                throw NotInWindowError.runtimeError("We did not find the magnitude of the peak in the batch.  Batch computation is not working")
            }
            
            let offset = i*windowSize
            let indexWherePeakOccurred = indexWherePeakOccurredInBatch! + offset
            
            peakMagnitudesIndexes[i] = indexWherePeakOccurred
            
            peaks.append(Peak(f2: self.getFrequency(withIndex: indexWherePeakOccurred), m1: samples[indexWherePeakOccurred-1], m2: peakMag,
                              m3: samples[indexWherePeakOccurred+1]))
        }
        
        
        return peaks
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
        
        return p.f2 + ((p.m1-p.m3)/(p.m3-2*p.m2+p.m1))*(deltaF/2)
    }
    
}

// Provided by Yannick here: https://stackoverflow.com/questions/45933149/swift-how-to-get-indexes-of-filtered-items-of-array
// used so that we can make use of
extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}

// Issue finding max value we thought was in window
enum NotInWindowError: Error {
    case runtimeError(String)
}
