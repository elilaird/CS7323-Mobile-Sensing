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
    
    func saveTremorData(tremorMagnitude: Float){
        // Get the current date
        let currentDateTime = Date()
        
        // Make a tremor data element
        let newTremorElement = TremorDataElement(tremorMagnitude: tremorMagnitude, timeRecorded: currentDateTime)
        
        // See if other data has been saved, if so load and append
//        let savedTremorData = userDefaults.array(forKey: tremorDataKey) as? [TremorDataElement] ?? [TremorDataElement]()
//        let decoded = userDefaults.data(forKey: tremorDataKey) ?? nil
//        var savedTremorData: [TremorDataElement] = []
//        if decoded != nil {
//            savedTremorData = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [TremorDataElement]
//        }
        
        let savedTremorData = getTremorData()
        
        print("Saved tremor data: \(savedTremorData)")
        print("Adding tremor element: \(newTremorElement)")
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
    
    func removeAllTremorData(){
        // Delete the currently saved data
        if userDefaults.bool(forKey: tremorDataKey){
            userDefaults.removeObject(forKey: tremorDataKey)
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
