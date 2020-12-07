//
//  ColorDistinctionTest.swift
//  common_sense
//
//  Created by Clay Harper on 12/6/20.
//

import Foundation
import UIKit

class ColorDistinction: UIViewController {

    @IBOutlet weak var leftColorView: UIView!
    @IBOutlet weak var rightColorView: UIView!
    @IBAction func yesClick(_ sender: Any) {
        // Call adjustColorUI with yes answered
        
    }
    @IBAction func noClick(_ sender: Any) {
        // Call adjustColorUI with no answered
    }
    
    // List of answers with delta e value
    var answers:[(correct: Bool, deltaE: Float)] = []
    var correctAnswersDeltaE:[Float] = []
    let numToGetCorrect = 10
    var currentDeltaE: Float? = nil
    var currentThreeColorPairs: [(Int, Int, Int)] = []
    var pairAffirmativeCount: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        leftColorView.layer.backgroundColor = UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1.0).cgColor
        rightColorView.layer.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        
    }
    
    func adjustColorUI(answeredAffirmative: Bool){
        if answeredAffirmative{
            correctAnswersDeltaE.append(currentDeltaE!)
            // Check if we are done on this testing screen
            if correctAnswersDeltaE.count == numToGetCorrect{
                // Print out the perceptibility score
                print(calcPercepScore())
                
                // Return to main screen
                segueBackToMain()
            }
        }
        
        // Update UI if negative or positive and did not return to main screen
        updateUI()
    }
    
    func updateUI(){
        
        // Gone through the 3 colors or have already answered 2 correctly
        if currentThreeColorPairs.count == 0 || pairAffirmativeCount == 2{
            // Adjust deltaE based on affirmative answers
            currentDeltaE = adjustDeltaE()
            
            // Get 3 new colors
            currentThreeColorPairs = getColorsWithDeltaE()
        }
    }
    
    func segueBackToMain(){
        
        // Return to main screen
        if let mainView = self.navigationController?.viewControllers.first{
            self.navigationController?.popToViewController(mainView, animated: true)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // Dummy function, should be replaced with an API call to our server later
    func getColorsWithDeltaE() -> [(Int, Int, Int)]{
        
        var colors: [(Int, Int, Int)]! = nil
        
        for _ in 1...3{
            let r = Int.random(in: 0..<256)
            let g = Int.random(in: 0..<256)
            let b = Int.random(in: 0..<256)
            colors!.append((r, g, b))
        }
        
        return colors
    }
    
    func getNewColorCombo(){
        
    }
    
    // Adjusts the deltaE value for the next test (increase or decrease the deltaE)
    func adjustDeltaE() -> Float{
        /*
         Note: based on our current perceptibility score, we want to really avoid having
         to decrease the deltaE because we are averaging their correct answers and don't
         want that to impact the result.
         */
        let numberOfCorrectlyAnswered = answered.filter{$0}.count
        
//        if numberOfCorrectlyAnswered
        return 0.0
    }
    
//    func adjustColorUI(answeredAffirmative: Bool){
//        if answeredAffirmative{
//            correctAnswersDeltaE.append()
//        }
//    }
    
    func controller(){
        // Run until we have 10 valid answers
        while correctAnswersDeltaE.count < 10{
            
            
            // Get 3 pairs of colors to test with approximately the same deltaE
            let threeColors = getColorsWithDeltaE(deltaE: 5.0)
            
            // For each of the colors (2 if first two answered correctly, 3 if tiebreaker needed)
            for colorPair in threeColors{
                // Adjust the UI
                
            }
            
        }
    }
    
    // Calculates the perceptibility score based on the user's answers for this specific test
    func calcPercepScore() -> Double{
        /*
         For now, I am making this a very simple function.  Basically, I am only going to
         look at the deltaE values that were answered correctly and take the average of them
         to produce what the person's delta e score is.  Then I will use that in my basic
         formula to convert that to the perceptibility score.  Maybe this could work and I just
         make the user keep answering questions until they get 10 answers correct?  That could
         be a good UI element too (like a cool progressbar or something?).  Going with this as
         the assumption right now so I should just be able to take the average of the deltaE values
         in the answered correctly array.  It is important that instead of narrowing in on what the
         user's deltaE is, that we instead start with a small deltaE and work our way up so that
         there aren't large outliers in the deltaE correctly answered array.
         */
//        var answeredCorrectly = 0
//        var addedDeltaE =
//        for elem in answers{
//
//            // Check if the answer was correct
//            if elem.correct == true {
//
//            } else{
//
//            }
        
        let sum = correctAnswersDeltaE.reduce(0, +)
        let avgDeltaE = Double(sum)/Double(numToGetCorrect)
        let maxDeltaE = (139032).squareRoot()
        
        // Using the basic perceptibility score formula of:
        /*
         Max deltaE = 372.86995051894434 (sqrt(139032))
            will have to be adjusted based on the penalizing factor
         K = penalizing factor so that deltaE of .001 apears much better than .1
         
         Max score will depend on Max DeltaE and K so that no one has a negative score
            (a blind person would be expected to get a 0)
         */
        
        let penalizingFactor = 2.3
        let maxPerceptibilityScore = maxDeltaE*penalizingFactor
        
        return maxPerceptibilityScore - (avgDeltaE*penalizingFactor)
    }


}
