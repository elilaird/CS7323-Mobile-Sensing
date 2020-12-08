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

import Foundation
import UIKit

class DeltaEAdjustor: NSObject {
    
    /*
     Idea here is that the view controller will get a deltaE value from this adjustor and then request 3 pairs
     of colors from the server with each pair being approximately the deltaE apart.  The user will then:
        
        1. Answer if they can tell the difference between the first pair
        2. Answer if they can tell the difference between the second pair
        3. (conditional) Answer if they can tell the difference between the third pair
            a. If they answer yes/no to the first 2, then no need for the 3rd one (assume they can tell/not tell the difference)
            b. If they split between yes/no on the first 2, use the 3rd as the tiebreaker
     
     
     couldDistinguishCurrentDeltaE is the best of 3 from the answers above.  The UI will ask to adjust the
     deltaE based on this criteria.
     
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
    var userAvgDeltaE = 0.0
    var currentDeltaE:Float = 1.0
    var couldDistinguishDeltaEValues:[Float] = []
    var couldNotDistinguishDeltaEValues:[Float] = []
    let stoppingCriteria:Float = 0.01
    
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
        if (lowestDeltaESeen - lowestDeltaENotSeen) <= stoppingCriteria{
            return true
        }
        return false
    }
    
    // Optional: Step 3 after color comparison
    func adjustDeltaE() -> Float{
        let distIncrement:Float = (lowestDeltaESeen-lowestDeltaENotSeen)*0.1
        currentDeltaE = lowestDeltaENotSeen + distIncrement
        return currentDeltaE
    }
    
    // Dummy, delete later
    func dummyShouldAdjustDeltaE() -> Bool{
        if couldDistinguishDeltaEValues.count == 3{
            return true
        }
        return false
    }
}

//func calculatePerceptibilityScore(deltaE: Float){
//    let maxDeltaE = (139032).squareRoot()
//
//
//}

struct Color {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat
}

struct ColorPair {
    let leftColor: Color
    let rightColor: Color
    let deltaE: Float
}

