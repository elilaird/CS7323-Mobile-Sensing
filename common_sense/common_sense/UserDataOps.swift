//
//  UserDataOps.swift
//  common_sense
//
//  Created by Clay Harper on 12/11/20.
//
//  This file is an interface with UserDefaults and allows for saving, appending, and loading data.

import Foundation

class DataInterface {
    
    let userDefaults = UserDefaults.standard
    
    func saveTremorData(tremorMagnitude: Float){
        // Get the current date
        let currentDateTime = Date()
        
        // Make a tremor data element
        
        // See if other data has been saved, if so load and append
        
        // Save array
    }
    
    func removeAllTremorData(){
        
    }
}

// Classes that will be saved, conform to NSCoding
class TremorDataElement: NSObject, NSCoding {
    var tremorMagnitude: Float
    var timeRecorded: Date
    
    init(tremorMagnitude: Float, timeRecorded: Date) {
        self.tremorMagnitude = tremorMagnitude
        self.timeRecorded = timeRecorded
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let tremorMagnitude = aDecoder.decodeFloat(forKey: "tremorMagnitude")
        let timeRecorded = aDecoder.decodeObject(forKey: "timeRecorded") as! Date
        self.init(tremorMagnitude: tremorMagnitude, timeRecorded: timeRecorded)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(tremorMagnitude, forKey: "tremorMagnitude")
        aCoder.encode(timeRecorded, forKey: "timeRecorded")
    }
}

class PerceptibilityScoreDataElement: NSObject, NSCoding {
    var perceptibilityScore: Float
    var timeRecorded: Date
    
    init(perceptibilityScore: Float, timeRecorded: Date) {
        self.perceptibilityScore = perceptibilityScore
        self.timeRecorded = timeRecorded
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let perceptibilityScore = aDecoder.decodeFloat(forKey: "perceptibilityScore")
        let timeRecorded = aDecoder.decodeObject(forKey: "timeRecorded") as! Date
        self.init(perceptibilityScore: perceptibilityScore, timeRecorded: timeRecorded)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(perceptibilityScore, forKey: "perceptibilityScore")
        aCoder.encode(timeRecorded, forKey: "timeRecorded")
    }
}

// TODO: change to real data that we are expecting.
class audioDataElement: NSObject, NSCoding {
    var perceptibilityScore: Float
    var timeRecorded: Date
    
    init(perceptibilityScore: Float, timeRecorded: Date) {
        self.perceptibilityScore = perceptibilityScore
        self.timeRecorded = timeRecorded
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let perceptibilityScore = aDecoder.decodeFloat(forKey: "perceptibilityScore")
        let timeRecorded = aDecoder.decodeObject(forKey: "timeRecorded") as! Date
        self.init(perceptibilityScore: perceptibilityScore, timeRecorded: timeRecorded)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(perceptibilityScore, forKey: "perceptibilityScore")
        aCoder.encode(timeRecorded, forKey: "timeRecorded")
    }
}
