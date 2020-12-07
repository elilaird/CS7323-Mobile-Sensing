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

    
    // New cleaner variables
    var affirmativeAnswersDeltaE:[Float] = []
    let numAffirmativeRequired = 10
    var currentDeltaE: Float = 1.0 // Start with the same value in the adjustor
    var currentColorPair = ColorPair(leftColor: Color(r: 0, g: 0, b: 0), rightColor: Color(r: 0, g: 0, b: 0), deltaE: 0.0)
    var colorPairsAtDeltaE: [ColorPair] = []
    var currentDeltaEAffirmativeCount: Int = 0
    
    let deAdjustor = DeltaEAdjustor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the first comparison
        colorPairsAtDeltaE = dummyGetColorsWithDeltaE()
        currentColorPair = colorPairsAtDeltaE.removeFirst()
        
    }
    
    
    @IBAction func yesClick(_ sender: Any) {
        // Add to affirmative answers
        affirmativeAnswersDeltaE.append(currentColorPair.deltaE)
        currentDeltaEAffirmativeCount += 1

        // Setup the next comparison
        setupNextComparison()
        
    }
    
    @IBAction func noClick(_ sender: Any) {
        // Still testing
        
        // Setup the next comparison
        setupNextComparison()

    }
    
    func setupNextComparison(){
        // Get the next color pair
        getNextPair()
        
        // Update the UI
        displayComparison()
    }
    
    func isLastComparison() -> Bool{
        return deAdjustor.dummyShouldAdjustDeltaE()
    }
    
    func displayComparison(){
        let leftColor = currentColorPair.leftColor
        let rightColor = currentColorPair.rightColor
        
        DispatchQueue.main.async {
            self.leftColorView.layer.backgroundColor = UIColor(red: leftColor.r/255, green: leftColor.g/255, blue: leftColor.b/255, alpha: 1.0).cgColor
            self.rightColorView.layer.backgroundColor = UIColor(red: rightColor.r/255, green: rightColor.g/255, blue: rightColor.b/255, alpha: 1.0).cgColor
        }
    }
    
    func segueBackToMain(){
        
        // Return to main screen
        if let mainView = self.navigationController?.viewControllers.first{
            self.navigationController?.popToViewController(mainView, animated: true)
        }
    }
    
    func getNextPair(){

        // If no more comparisons at the current deltaE, get new colors -- TOD0: make work with deltaE ajdust algo
        // If went through all 3 pairs or (2/3 have already been answered yes/no) -- best 2/3
        if colorPairsAtDeltaE.count == 0 || (currentDeltaEAffirmativeCount == 0 && colorPairsAtDeltaE.count == 1) || currentDeltaEAffirmativeCount == 2{
            // Use algo to get new deltaE
            if currentDeltaEAffirmativeCount == 2{
                deAdjustor.updateCouldDistinguish(couldDistinguishCurrentDeltaE: true)
            }else{
                deAdjustor.updateCouldDistinguish(couldDistinguishCurrentDeltaE: false)
            }
            
            // Check if we have enough affirmative answers
            if isLastComparison(){
                // Segue back to main screen
                segueBackToMain()  // Deallocate these variables or is this done automatically?? -- TODO
            }
            
            
            // Request pairs from server with deltaE values
            
            // DUMMY DATA: just making it run right now
            colorPairsAtDeltaE = dummyGetColorsWithDeltaE()
            
            // Reset variables
            currentDeltaEAffirmativeCount = 0
        }
        
        // Set the current pair
        currentColorPair = colorPairsAtDeltaE.removeFirst()
    }
    
    
    // DUMMY FUNCTIONS FOR RIGHT NOW
    func dummyGetColorsWithDeltaE() -> [ColorPair]{

        var colors: [ColorPair] = []
        
        for _ in 1...3{
            var rr = Int.random(in: 0..<256)
            var rg = Int.random(in: 0..<256)
            var rb = Int.random(in: 0..<256)
            
            var (cr, cg, cb) = dummyMakeCGFloatColor(color: (rr, rg, rb))
            let color = Color(r: cr, g: cg, b: cb)
            
            rr = Int.random(in: 0..<256)
            rg = Int.random(in: 0..<256)
            rb = Int.random(in: 0..<256)
            
            (cr, cg, cb) = dummyMakeCGFloatColor(color: (rr, rg, rb))
            let color2 = Color(r: cr, g: cg, b: cb)
            
            let deltaE = Float.random(in: 0.0..<20.0)
            colors.append(ColorPair(leftColor: color, rightColor: color2, deltaE: deltaE))
        }
        
        return colors
    }
    
    func dummyMakeCGFloatColor(color: (Int, Int, Int)) -> (CGFloat, CGFloat, CGFloat){
        let (r, g, b) = color
        let newR = CGFloat(r)
        let newG = CGFloat(g)
        let newB = CGFloat(b)
        return (newR, newG, newB)
    }
    
}

extension Collection where Iterator.Element == Int {
    var convertToDouble: [Double] {
        return compactMap{ Double($0) }
    }
    var convertToFloat: [Float] {
        return compactMap{ Float($0) }
    }
}
