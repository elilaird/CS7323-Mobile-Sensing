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
    let tremorDataKey = "tremorData"
    let perceptibilityKey = "perceptibilityData"
    let audioKey = "audioData"
    
    func getTremorData() -> [TremorDataElement]{
        let decoded = userDefaults.data(forKey: tremorDataKey) ?? nil
        var savedTremorData: [TremorDataElement] = []
        if decoded != nil {
            savedTremorData = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [TremorDataElement]
        }
        
        return savedTremorData
    }
    
    func getPerceptibilityData() -> [PerceptibilityScoreDataElement]{
        let decoded = userDefaults.data(forKey: perceptibilityKey) ?? nil
        var savedPerceptibilityData: [PerceptibilityScoreDataElement] = []
        if decoded != nil {
            savedPerceptibilityData = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [PerceptibilityScoreDataElement]
        }
        
        return savedPerceptibilityData
    }
    
    func getAudioData() -> [AudioDataElement]{
        let decoded = userDefaults.data(forKey: audioKey) ?? nil
        var savedAudioData: [AudioDataElement] = []
        if decoded != nil {
            savedAudioData = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [AudioDataElement]
        }
        
        return savedAudioData
    }
    
    func saveTremorData(tremorMagnitude: Float){
        // Get the current date
        let currentDateTime = Date()
        
        // Make a tremor data element
        let newTremorElement = TremorDataElement(tremorMagnitude: tremorMagnitude, timeRecorded: currentDateTime)
        
        // See if other data has been saved, if so load and append
        let savedTremorData = getTremorData()
        
        var dataArray = [newTremorElement]
        
        if savedTremorData.count > 0{
            // Make new data array
            dataArray = savedTremorData + [newTremorElement]
            
            // Delete the currently saved data
            userDefaults.removeObject(forKey: tremorDataKey)
        }
        
        // Encode the data as data (adapted from: https://stackoverflow.com/questions/29986957/save-custom-objects-into-nsuserdefaults)
        let encoded: Data = NSKeyedArchiver.archivedData(withRootObject: dataArray)
        
        // Save array
        userDefaults.set(encoded, forKey: tremorDataKey)
        userDefaults.synchronize()
    }
    
    func savePerceptibilityData(perceptibilityScore: Float){
        // Get the current date
        let currentDateTime = Date()
        
        // Make a tremor data element
        let newPerceptibilityElement = PerceptibilityScoreDataElement(perceptibilityScore: perceptibilityScore, timeRecorded: currentDateTime)
        
        // See if other data has been saved, if so load and append
        let savedPerceptibilityData = getPerceptibilityData()
        
        var dataArray = [newPerceptibilityElement]
        
        if savedPerceptibilityData.count > 0{
            // Make new data array
            dataArray = savedPerceptibilityData + [newPerceptibilityElement]
            
            // Delete the currently saved data
            userDefaults.removeObject(forKey: perceptibilityKey)
        }
        
        // Encode the data as data (adapted from: https://stackoverflow.com/questions/29986957/save-custom-objects-into-nsuserdefaults)
        let encoded: Data = NSKeyedArchiver.archivedData(withRootObject: dataArray)
        
        // Save array
        userDefaults.set(encoded, forKey: perceptibilityKey)
        userDefaults.synchronize()
    }
    
    func saveAudioData(lowFrequencyAtdB: Float, highFrequencyAtdB:Float, dB: Float, lowFrequencyAtMaxdB: Float, highFrequencyAtMaxdB:Float,
                       maxdB: Float){
        // Get the current date
        let currentDateTime = Date()
        
        // Make a tremor data element
        let newAudioElement = AudioDataElement(lowFrequencyAtdB: lowFrequencyAtdB, highFrequencyAtdB: highFrequencyAtdB, dB: dB,
                                               lowFrequencyAtMaxdB: lowFrequencyAtMaxdB, highFrequencyAtMaxdB: highFrequencyAtMaxdB,
                                               maxdB: maxdB, timeRecorded: currentDateTime)
        
        // See if other data has been saved, if so load and append
        let savedAudioData = getAudioData()
        
        var dataArray = [newAudioElement]
        
        if savedAudioData.count > 0{
            // Make new data array
            dataArray = savedAudioData + [newAudioElement]
            
            // Delete the currently saved data
            userDefaults.removeObject(forKey: audioKey)
        }
        
        // Encode the data as data (adapted from: https://stackoverflow.com/questions/29986957/save-custom-objects-into-nsuserdefaults)
        let encoded: Data = NSKeyedArchiver.archivedData(withRootObject: dataArray)
        
        // Save array
        userDefaults.set(encoded, forKey: audioKey)
        userDefaults.synchronize()
    }
    
    func removeAllTremorData(){
        // Delete the currently saved data
        if userDefaults.bool(forKey: tremorDataKey){
            userDefaults.removeObject(forKey: tremorDataKey)
        }
    }
    
    func removeAllPerceptibilityData(){
        // Delete the currently saved data
        if userDefaults.bool(forKey: perceptibilityKey){
            userDefaults.removeObject(forKey: perceptibilityKey)
        }
    }
    
    func removeAllAudioData(){
        // Delete the currently saved data
        if userDefaults.bool(forKey: audioKey){
            userDefaults.removeObject(forKey: audioKey)
        }
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
class AudioDataElement: NSObject, NSCoding {
    var lowFrequencyAtdB: Float
    var highFrequencyAtdB: Float
    var dB: Float
    var lowFrequencyAtMaxdB: Float
    var highFrequencyAtMaxdB: Float
    var maxdB: Float
    var timeRecorded: Date
    
    init(lowFrequencyAtdB: Float, highFrequencyAtdB:Float, dB: Float, lowFrequencyAtMaxdB: Float, highFrequencyAtMaxdB:Float,
         maxdB: Float, timeRecorded: Date) {
        self.lowFrequencyAtdB = lowFrequencyAtdB
        self.highFrequencyAtdB = highFrequencyAtdB
        self.dB = dB
        self.lowFrequencyAtMaxdB = lowFrequencyAtMaxdB
        self.highFrequencyAtMaxdB = highFrequencyAtMaxdB
        self.maxdB = maxdB
        self.timeRecorded = timeRecorded
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let lowFrequencyAtdB = aDecoder.decodeFloat(forKey: "lowFrequencyAtdB")
        let highFrequencyAtdB = aDecoder.decodeFloat(forKey: "highFrequencyAtdB")
        let dB = aDecoder.decodeFloat(forKey: "dB")
        let lowFrequencyAtMaxdB = aDecoder.decodeFloat(forKey: "lowFrequencyAtMaxdB")
        let highFrequencyAtMaxdB = aDecoder.decodeFloat(forKey: "highFrequencyAtMaxdB")
        let maxdB = aDecoder.decodeFloat(forKey: "maxdB")
        let timeRecorded = aDecoder.decodeObject(forKey: "timeRecorded") as! Date
        self.init(lowFrequencyAtdB: lowFrequencyAtdB, highFrequencyAtdB: highFrequencyAtdB, dB: dB, lowFrequencyAtMaxdB: lowFrequencyAtMaxdB,
                  highFrequencyAtMaxdB: highFrequencyAtMaxdB, maxdB: maxdB, timeRecorded: timeRecorded)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(lowFrequencyAtdB, forKey: "lowFrequencyAtdB")
        aCoder.encode(highFrequencyAtdB, forKey: "highFrequencyAtdB")
        aCoder.encode(dB, forKey: "dB")
        aCoder.encode(lowFrequencyAtMaxdB, forKey: "lowFrequencyAtMaxdB")
        aCoder.encode(highFrequencyAtMaxdB, forKey: "highFrequencyAtMaxdB")
        aCoder.encode(maxdB, forKey: "maxdB")
        aCoder.encode(timeRecorded, forKey: "timeRecorded")
    }
}
