//
//  VisionResultController.swift
//  common_sense
//
//  Created by Clay Harper on 12/12/20.
//

import Foundation
import UIKit

class VisionResultController: UIViewController {

    let dataInterface = DataInterface()
    var allPerceptibilityScores: [Float] = []
    var currentScore: Float = 0
    @IBOutlet weak var visionScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.allPerceptibilityScores = loadData()
        self.currentScore = self.allPerceptibilityScores.last ?? 0
        
        self.visionScoreLabel.text = String(Int(self.currentScore))
        // Do any additional setup after loading the view.
    }
    
    func loadData() -> [Float]{
        let percepData = dataInterface.getPerceptibilityData()
        
        var percepScores = [Float](repeating:0, count:percepData.count)
        
        for i in 0...percepData.count - 1{
            percepScores[i] = percepData[i].perceptibilityScore
        }
        
        return percepScores
    }
    
    @IBAction func returnToLanding(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
