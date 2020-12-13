//
//  VisionResultController.swift
//  common_sense
//
//  Created by Clay Harper on 12/12/20.
//

import Foundation
import UIKit
import Charts

class VisionResultController: UIViewController {

    let dataInterface = DataInterface()
    var allPerceptibilityScores: [Float] = []
    var currentScore: Float = 0
    @IBOutlet weak var visionScoreLabel: UILabel!
    @IBOutlet weak var lineChart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let startGrad = UIColor(red: 118/255, green: 180/255, blue: 189/255, alpha: 1.0).cgColor
        gradientLayer.colors = [startGrad, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)

        self.allPerceptibilityScores = loadData()
        self.currentScore = self.allPerceptibilityScores.last ?? 0
        
        self.visionScoreLabel.text = String(Int(self.currentScore))
        // Do any additional setup after loading the view.
        
        
        // CHART
        // - Sample Data
        let a = [1,2,3,4,5]
        let b = [6,7,8,9,10]
        let c = 5
        
        // - Function Call, both arrays have to be doubles so you may have to map them
        generateChart(xVals: a.map{Double($0)}, yVals: b.map{Double($0)}, length: c)
    }
    
    func loadData() -> [Float]{
        let percepData = dataInterface.getPerceptibilityData()
        
        var percepScores = [Float](repeating:0, count:percepData.count)
        
        for i in 0...percepData.count - 1{
            percepScores[i] = percepData[i].perceptibilityScore
        }
        
        return percepScores
    }
    
    func generateChart(xVals: [Double], yVals: [Double], length: Int){
        var lineChartEntry = [ChartDataEntry]()
        for i in 0..<length{
            let value = ChartDataEntry(x: xVals[i], y: yVals[i])
            lineChartEntry.append(value)
        }
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "Number")
        line1.colors = [NSUIColor.blue]
        let data = LineChartData()
        data.addDataSet(line1)
        lineChart.data = data
        lineChart.legend.enabled = false
        lineChart.xAxis.enabled = false
        lineChart.chartDescription?.text = ""
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
