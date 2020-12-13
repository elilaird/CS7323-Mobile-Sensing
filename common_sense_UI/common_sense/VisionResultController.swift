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
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var graphRangeLabel: UILabel!
    
    let pastelRed = UIColor(red: 255/255, green: 105/255, blue: 97/255, alpha: 1.0)
    let pastelGreen = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let startGrad = UIColor(red: 118/255, green: 180/255, blue: 189/255, alpha: 1.0).cgColor
        gradientLayer.colors = [startGrad, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        self.doneButton.layer.cornerRadius = 9
        self.doneButton.backgroundColor = self.pastelGreen
        self.doneButton.setTitleColor(.white, for: .normal)


        self.allPerceptibilityScores = loadData()
        self.currentScore = self.allPerceptibilityScores.last ?? 0
        
        self.visionScoreLabel.text = String(Int(self.currentScore))
        // Do any additional setup after loading the view.
        
        // CHART
        let x = Array(stride(from: 0, to: allPerceptibilityScores.count, by:1)).map {Double($0)}
        
        let percepResults = dataInterface.getPerceptibilityData()
        let firstTime = percepResults.first?.timeRecorded ?? Date()
        let mostRecentTime = percepResults.last?.timeRecorded ?? Date()
        let sinceFirstTime = firstTime.timeAgoDisplay()
        let sinceMostRecentTime = mostRecentTime.timeAgoDisplay()
        self.graphRangeLabel.text = "From " + sinceFirstTime + " to " + sinceMostRecentTime
        self.graphRangeLabel.adjustsFontSizeToFitWidth = true
        
        // - Function Call, both arrays have to be doubles so you may have to map them
        generateChart(xVals: x, yVals: allPerceptibilityScores.map{Double($0)}, length: x.count)
        
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
