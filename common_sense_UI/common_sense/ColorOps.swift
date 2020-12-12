//
//  ColorOps.swift
//  common_sense
//
//  Created by Clay Harper on 12/7/20.
//

/*
    This class is an algorithm to adjust the deltaE value based on affirmative (can tell
    difference between colors) answers from the user so that we can calculate the
    perceptibility score for the user.
 */

let SERVER_URL = "http://35.239.233.247:8000"

import Foundation
import UIKit

class DeltaEAdjustor: NSObject {
    
    /*
     Idea here is that the view controller will get a deltaE value from this adjustor and then request 3 pairs
     of colors from the server with each pair being approximately the deltaE apart.  The user will then:
    
     If they could distinguish with the current deltaE, we need to make the next deltaE harder to see.
     If they could not distinguish, we need to increase the deltaE (easier to see)
     
     We want to narrow in on their deltaE, so we need a better algo, but for now, just increasing the deltaE by
     10% until they can see, then adjust deltaE based on this value:
     
            notDist = Max(could not distinguish deltaE)
            dist = Min(could distinguish deltaE)
     
            zeroing in between notDist and dist
                
            distIncrement = 10% of (dist - notDist)
     
            testNotDist = notDist + distIncrement
     
            and then see if they can tell the values apart.
            replace notDist and dist accordingly, then repeat
                stopping criteria: (dist - notDist) <= .01 (may want to adjust depending on how we calculate perceptibility score)
     
     */
    
    // This should be initialized with something from disk or server (in case the user has used the app before)
    var currentDeltaE:Float = 1.0
    var couldDistinguishDeltaEValues:[Float] = []
    var couldNotDistinguishDeltaEValues:[Float] = []
    let stoppingCriteria:Float = 0.1
    
    var lowestDeltaESeen:Float = 1000.0 // init to high value to avoid issues
    var lowestDeltaENotSeen:Float = 1.0
    
    // Step 1 after color comparison
    func updateCouldDistinguish(couldDistinguishCurrentDeltaE: Bool){
        //Update tracking variables
        if couldDistinguishCurrentDeltaE{
            couldDistinguishDeltaEValues.append(currentDeltaE)
            lowestDeltaESeen = couldDistinguishDeltaEValues.min()!
        }else{
            couldNotDistinguishDeltaEValues.append(currentDeltaE)
            lowestDeltaENotSeen = couldNotDistinguishDeltaEValues.max()!
        }
    }
    
    // Step 2 after color comparison
    func shouldAdjustDeltaE()->Bool{
        // Make sure we want to continue
        if (lowestDeltaESeen - lowestDeltaENotSeen) <= stoppingCriteria {
            return true
        }
        return false
    }
    
    // Optional: Step 3 after color comparison
    func adjustDeltaE() -> Float{
        // If calling the first time, return the intialized value of 1.0
        if couldDistinguishDeltaEValues.count == 0 && couldNotDistinguishDeltaEValues.count == 0{
            return currentDeltaE
        }
        
        // If the user hasn't seen any of the distinctions yet, just increase by 10%
        if couldDistinguishDeltaEValues.count == 0 {
            currentDeltaE *= 1.1
            return currentDeltaE
        }
        
        // User has seen differences and we want to zero in on their ability
        let distIncrement:Float = (lowestDeltaESeen-lowestDeltaENotSeen)*0.1
        currentDeltaE = lowestDeltaENotSeen + distIncrement
        return currentDeltaE
    }
    
    func exp(power: Double) -> Double{
        return pow(M_E, power)
    }

    func calculatePerceptibilityScore() -> Float{
        let deltaE = couldDistinguishDeltaEValues.min()
        print("Best deltaE: \(String(describing: deltaE))")
        let scaled_sigmoid = 450*(1/(1 + exp(power: -1*Double(deltaE!)/10)))
        
        return Float(450 - scaled_sigmoid)
    }

}

struct Color {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat
}

struct ColorPair {
    let leftColor: Color
    let rightColor: Color
}

