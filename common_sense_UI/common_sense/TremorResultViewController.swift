//
//  VisionResultController.swift
//  common_sense
//
//  Created by Clay Harper on 12/12/20.
//

import Foundation
import UIKit

class TremorResultController: UIViewController {

    let dataInterface = DataInterface()
    var allTremorValues: [Float] = []
    var currentScore: Float = 0
    @IBOutlet weak var tremorMagLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.allTremorValues = loadData()
        self.currentScore = self.allTremorValues.last ?? 0
        
        self.tremorMagLabel.text = String(format: "%.2f", self.currentScore)
        // Do any additional setup after loading the view.
    }
    
    func loadData() -> [Float]{
        let tremorData = dataInterface.getTremorData()
        
        var tremorMags = [Float](repeating:0, count:tremorData.count)
        
        for i in 0...tremorData.count - 1{
            tremorMags[i] = tremorData[i].tremorMagnitude
        }
        
        return tremorMags
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
