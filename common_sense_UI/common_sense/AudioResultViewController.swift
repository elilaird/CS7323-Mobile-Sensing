//
//  AudioResultViewController.swift
//  common_sense
//
//  Created by Eli Laird on 12/12/20.
//

import UIKit
import Charts

class AudioResultViewController: UIViewController {


    @IBOutlet weak var hearingRange: UILabel!
    @IBOutlet weak var lineChart: LineChartView!
    
    var dataInterface: DataInterface = DataInterface()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let startGrad = UIColor(red: 88/255, green: 102/255, blue: 139/255, alpha: 1.0).cgColor
        gradientLayer.colors = [startGrad, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let audioResults = dataInterface.getAudioData()
        let high = getFormattedFrequency(with: audioResults.last!.highFrequencyAtMaxdB)
        let low = getFormattedFrequency(with: audioResults.last!.lowFrequencyAtMaxdB)

        self.hearingRange.adjustsFontSizeToFitWidth = true
        self.hearingRange.text = String(format: "%@ - %@", low, high)
        
        // CHART
        // - Sample Data
//        let a = [1,2,3,4,5]
//        let b = [6,7,8,9,10]
//        let c = [1,2,3,4,5]
//        let d = [6,7,8,9,10]
//        let e = 5
    
        var yHigh:[Double] = []
        var yLow:[Double] = []
        let x = Array(stride(from: 0, to: audioResults.count, by:1)).map {Double($0)}

        for audioE in audioResults {
            yHigh.append(Double(audioE.highFrequencyAtMaxdB))
            yLow.append(Double(audioE.lowFrequencyAtMaxdB))
        }
        
        generateChart(xValsLow: x, yValsLow: yLow, xValsHigh: x, yValsHigh: yHigh, length: x.count)
        
        // - Function Call, both arrays have to be doubles so you may have to map them
//        generateChart(xValsLow: a.map{Double($0)}, //lower bound x values array
//                      yValsLow: b.map{Double($0)}, //lower bound y values array
//                      xValsHigh: c.map{Double($0)}, //upper bound x values array
//                      yValsHigh: d.map{Double($0)}, //upper bound y values array
//                      length: e) //number of data points

    }
    
    func generateChart(xValsLow: [Double], yValsLow: [Double], xValsHigh: [Double], yValsHigh: [Double], length: Int){
        var lineChartEntryLow = [ChartDataEntry]()
        var lineChartEntryHigh = [ChartDataEntry]()
        for i in 0..<length{
            let valueLow = ChartDataEntry(x: xValsLow[i], y: yValsLow[i])
            let valueHigh = ChartDataEntry(x: xValsHigh[i], y: yValsHigh[i])
            lineChartEntryLow.append(valueLow)
            lineChartEntryHigh.append(valueHigh)
        }
        let lineLow = LineChartDataSet(entries: lineChartEntryLow, label: "Number")
        let lineHigh = LineChartDataSet(entries: lineChartEntryHigh, label: "Number")
        lineLow.colors = [NSUIColor.blue]
        lineHigh.colors = [NSUIColor.red]
        let data = LineChartData()
        data.addDataSet(lineLow)
        data.addDataSet(lineHigh)
        lineChart.data = data
        lineChart.legend.enabled = false
        lineChart.xAxis.enabled = false
        lineChart.chartDescription?.text = ""
    }
    
    func getFormattedFrequency(with freq:Float) -> String{
        let formatter = MeasurementFormatter()
        let hertz = Measurement(value: Double(freq), unit: UnitFrequency.hertz)
        return formatter.string(from: hertz)
    }
    
    @IBAction func returnToLanding(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
    }

}
