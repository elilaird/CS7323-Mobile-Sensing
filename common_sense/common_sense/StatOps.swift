//
//  StatOps.swift
//  common_sense
//
//  Created by Clay Harper on 12/9/20.
//

import Foundation
import SigmaSwiftStatistics

class CorrelationStats: NSObject {
    var xSeries: [Float]
    var ySeries: [Float]
    var lowThreshold: Float = 0.25
    var mediumThreshold: Float = 0.5
    var xSeriesName: String = "xSeries"
    var ySeriesName: String = "ySeries"
    let minElements: Int = 6
    
    
    // For default values
    init(xSeries: [Float], ySeries: [Float]){
        self.xSeries = xSeries
        self.ySeries = ySeries
    }
    
    // For default thresholds and with names
    init(xSeries: [Float], ySeries: [Float], xSeriesName: String, ySeriesName: String){
        self.xSeries = xSeries
        self.ySeries = ySeries
        self.xSeriesName = xSeriesName
        self.ySeriesName = ySeriesName
    }
    
    // For custom thresholds
    init(xSeries: [Float], ySeries: [Float], xSeriesName: String, ySeriesName: String, lowThreshold: Float, mediumThreshold: Float){
        self.xSeries = xSeries
        self.ySeries = ySeries
        self.lowThreshold = lowThreshold
        self.mediumThreshold = mediumThreshold
        self.xSeriesName = xSeriesName
        self.ySeriesName = ySeriesName
    }
 
    private func calculateCorrelation() -> Float{
        return Float(Sigma.pearson(x: self.xSeries.convertToDouble, y: self.ySeries.convertToDouble) ?? 0.0)
    }
    
    func interpretCorrelation(correl: Float) -> String{
        let absCorrel = abs(correl)
        
        // Small correlation
        if absCorrel <= lowThreshold{
            return "no_correlation"
        }
        
        // Medium correlation
        if absCorrel > lowThreshold && absCorrel <= mediumThreshold{
            if correl > 0 {
                return "medium_positive"
            }
            return "medium_negative"
        }
        
        // Else: large correlation
        if correl > 0{
            return "large_positive"
        }
        return "large_negative"
    }
    
    func getCorrelation() throws -> Float{
        // Example usage: let correl = try? cs.getCorrelation()
        // Intentionally made this difficult so the 2 errors below give good error messages and so it's harder to mess up
        // Get the counts in both x and y series
        let xCount = self.xSeries.count
        let yCount = self.ySeries.count
        if xCount != yCount {
            throw MismatchingShapes.runtimeError("X-Series and Y-Series must be the same shape, got \(xCount) and \(yCount)")
        }

        // Make sure we have enough elements in the x and y series (already verified same length at this point)
        if xCount < self.minElements {
            throw TooFewElements.runtimeError("X-Series and Y-Series must at least have \(self.minElements) elements, got \(xCount) and \(yCount)")
        }
        
        // Calculate the correlation
        let correl = self.calculateCorrelation()

        return correl
    }
    
}

enum MismatchingShapes: Error {
    case runtimeError(String)
}

enum TooFewElements: Error {
    case runtimeError(String)
}

extension Collection where Iterator.Element == Float {
    var convertToDouble: [Double] {
        return compactMap{ Double($0) }
    }
    var convertToFloat: [Float] {
        return compactMap{ Float($0) }
    }
}
