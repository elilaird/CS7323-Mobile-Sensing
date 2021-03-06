//
//  SensePreviewCell.swift
//  common_sense
//
//  Created by Matthew Lee on 12/8/20.
//
import FoldingCell
import UIKit
import Charts


class SensePreviewCell: FoldingCell {

    @IBOutlet weak var lastCheckupLabel: UILabel!
    @IBOutlet weak var senseIcon: UIImageView!
    @IBOutlet weak var expandedHeader: UILabel!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet var latestScoreLabels: [UILabel]!
    @IBOutlet var scoreUnitsLabels: [UILabel]!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var latestScoreCaption: UILabel!
    @IBOutlet weak var graphRangeLabel: UILabel!
    
    var takeTestAction: ((SensePreviewCell) -> Void)?
    var imageName: String = ""
    

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Formatting
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        testButton.layer.cornerRadius = 10
        
        // Load up chart
        /*
        var lineChartEntry = [ChartDataEntry]()
        for i in stride(from: 0, to: 50, by: 5){
            let value = ChartDataEntry(x: Double(i), y: Double(i))
            lineChartEntry.append(value)
        }
        
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "Number")
        line1.colors = [NSUIColor.blue]
        let data = LineChartData()
        data.addDataSet(line1)
        lineChart.data = data
        lineChart.chartDescription?.text = "Yeet"
        */
        
        //let a = [1,2,3,4,5]
        //let b = [6,7,8,9,10]
        //let c = 5
        //loadDataChart(xVals: a.map{Double($0)}, yVals: b.map{Double($0)}, length: c)
        
        // Initialization code
    }
    
    @IBAction func takeTest(_ sender: Any) {
        takeTestAction?(self)
    }
    
    func configure(imageName: String, name: String, color: UIColor, lastCheckup: Int = 0, scoreUnits: String = "", latestScore: String = "N/A"){
        self.senseIcon?.image = UIImage(named: imageName)
        self.expandedHeader.text = name
        self.foregroundView.backgroundColor = color
        self.backViewColor = color
        self.expandedHeader.backgroundColor = color
        self.testButton.backgroundColor = color
        if lastCheckup == 0{
            self.lastCheckupLabel.text = "Last Checkup: Today"
        }else if lastCheckup == 1{
            self.lastCheckupLabel.text = "Last Checkup: Yesterday"
        }else{
            self.lastCheckupLabel.text = "Last Checkup: \(lastCheckup) days ago"
        }
        for unitLabel in scoreUnitsLabels{
            unitLabel.text = scoreUnits
        }
        for label in latestScoreLabels{
            label.text = latestScore
        }
        
    }
    
    func loadSingleLineDataChart(xVals: [Double], yVals: [Double], length: Int){
        var lineChartEntry = [ChartDataEntry]()
        for i in 0..<length{
            let value = ChartDataEntry(x: xVals[i], y: yVals[i])
            lineChartEntry.append(value)
        }
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "Number")
        line1.colors = [NSUIColor.red]
        let data = LineChartData()
        data.addDataSet(line1)
        lineChart.data = data
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.legend.enabled = false
        lineChart.xAxis.enabled = false
        lineChart.chartDescription?.text = ""
    }
    
    func loadDoubleLineDataChart(xValsLow: [Double], yValsLow: [Double], xValsHigh: [Double], yValsHigh: [Double], length: Int){
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
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
