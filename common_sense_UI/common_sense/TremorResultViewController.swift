//
//  VisionResultController.swift
//  common_sense
//
//  Created by Clay Harper on 12/12/20.
//

import Foundation
import UIKit
import Charts

class TremorResultController: UIViewController {

    let dataInterface = DataInterface()
    var allTremorValues: [Float] = []
    var currentScore: Float = 0
    @IBOutlet weak var tremorMagLabel: UILabel!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var graphRangeLabel: UILabel!
    
    let pastelRed = UIColor(red: 255/255, green: 105/255, blue: 97/255, alpha: 1.0)
    let pastelGreen = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let startGrad = UIColor(red: 189/255, green: 234/255, blue: 238/255, alpha: 1.0).cgColor
        gradientLayer.colors = [startGrad, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        self.doneButton.layer.cornerRadius = 9
        self.doneButton.backgroundColor = self.pastelGreen
        self.doneButton.setTitleColor(.white, for: .normal)

        self.allTremorValues = loadData()
        self.currentScore = self.allTremorValues.last ?? 0
        
        self.tremorMagLabel.text = String(format: "%.2f", self.currentScore)
        // Do any additional setup after loading the view.
        
        
        // CHART
        let x = Array(stride(from: 0, to: allTremorValues.count, by:1)).map {Double($0)}
        
        let tremorResults = dataInterface.getTremorData()
        let firstTime = tremorResults.first?.timeRecorded ?? Date()
        let mostRecentTime = tremorResults.last?.timeRecorded ?? Date()
        let sinceFirstTime = firstTime.timeAgoDisplay()
        let sinceMostRecentTime = mostRecentTime.timeAgoDisplay()
        self.graphRangeLabel.text = "From " + sinceFirstTime + " to " + sinceMostRecentTime
        self.graphRangeLabel.adjustsFontSizeToFitWidth = true
        
        // - Function Call, both arrays have to be doubles so you may have to map them
        generateChart(xVals: x, yVals: allTremorValues.map{Double($0)}, length: x.count)
    }
    
    func loadData() -> [Float]{
        let tremorData = dataInterface.getTremorData()
        
        var tremorMags = [Float](repeating:0, count:tremorData.count)
        
        for i in 0...tremorData.count - 1{
            tremorMags[i] = tremorData[i].tremorMagnitude
        }
        
        return tremorMags
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
