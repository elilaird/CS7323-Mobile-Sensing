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
    
    var takeTestAction: ((SensePreviewCell) -> Void)?
    var imageName: String = ""
    

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
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
        
        
        // Initialization code
    }
    
    @IBAction func takeTest(_ sender: Any) {
        takeTestAction?(self)
    }
    
    func configure(imageName: String, name: String){
        self.senseIcon?.image = UIImage(named: imageName)
        self.expandedHeader.text = name
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
