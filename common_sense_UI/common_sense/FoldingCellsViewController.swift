//
//  FoldingCellsView.swift
//  common_sense
//
//  Created by Matthew Lee on 12/7/20.
//


import UIKit
import FoldingCell

class FoldingCellsViewController: UITableViewController {

    enum Const {
        static let closeCellHeight: CGFloat = 200
        static let openCellHeight: CGFloat = 514
        static let rowsCount = 10
    }
    
    var cellHeights: [CGFloat] = []
    
    var cells: [String] = ["Hearing", "Vision", "Tremors"]
    var cellIcons: [String] = ["ear", "eye", "hand"]
    var cellColors: [UIColor] = [UIColor(red: 0.35, green: 0.40, blue: 0.55, alpha: 1.00),
                                 UIColor(red: 0.46, green: 0.71, blue: 0.74, alpha: 1.00),
                                 UIColor(red: 0.74, green: 0.92, blue: 0.93, alpha: 1.00)]
    
    let emptyScore:String = "Get Started!"
    let emptyUnits:String = ""
    

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //uncomment to reset user data
        //UserDefaults.standard.reset()
//        let domain = Bundle.main.bundleIdentifier!
//        UserDefaults.standard.removePersistentDomain(forName: domain)
//        UserDefaults.standard.synchronize()
        
        setup()
        self.view.backgroundColor = UIColor(named: "red")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    // MARK: Helpers
    private func setup() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableView.automaticDimension
        //tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
    }
    
    func getFormattedFrequency(with freq:Float) -> String{
        let formatter = MeasurementFormatter()
        let hertz = Measurement(value: Double(freq), unit: UnitFrequency.hertz)
        return formatter.string(from: hertz)
    }
    
    // MARK: Actions
    @objc func refreshHandler() {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            if #available(iOS 10.0, *) {
                self?.tableView.refreshControl?.endRefreshing()
            }
            self?.tableView.reloadData()
        })
    }
}


// MARK: - TableView

extension FoldingCellsViewController {

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 3
    }

    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as SensePreviewCell = cell else {
            return
        }

        cell.backgroundColor = .clear

        if cellHeights[indexPath.row] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }

        //cell.number = indexPath.row
    }

    
    // ***** ADD LOGIC IN THIS FUNCTION FOR CELLS *****
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! SensePreviewCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        var last = Date()
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        
        // Pass values into commented fields
        cell.configure(imageName: cellIcons[indexPath.row], // Icon name
                       name: cells[indexPath.row], // Name of sense
                       color: cellColors[indexPath.row] // Cell Color
                       //lastCheckup: Int,
                       //scoreUnits: String,
                       //latestScore: String
                       )
        
        if indexPath.row == 0 { // Call special 2 line graph for hearing

            let dataInterface:DataInterface = DataInterface()
            
            
            let audioResults = dataInterface.getAudioData()
            var yHigh:[Double] = []
            var yLow:[Double] = []
            let x = Array(stride(from: 0, to: audioResults.count, by:1)).map {Double($0)}

            for audioE in audioResults {
                yHigh.append(Double(audioE.highFrequencyAtMaxdB))
                yLow.append(Double(audioE.lowFrequencyAtMaxdB))
            }
            
            if audioResults.count > 0{
                cell.latestScoreCaption.isHidden = false
            }
            else{
                cell.latestScoreCaption.isHidden = true
            }
            
            cell.loadDoubleLineDataChart(xValsLow: x, yValsLow: yLow, xValsHigh: x, yValsHigh: yHigh, length: x.count)
            
            for label in cell.latestScoreLabels {
                label.adjustsFontSizeToFitWidth = true
                let latestResult = Int(audioResults.last?.highFrequencyAtMaxdB ?? -1)
                var displayResult = String(latestResult)
                if latestResult == -1{
                    displayResult = self.emptyScore
                }
                label.text = displayResult
            }
            for unit in cell.scoreUnitsLabels {
                let latestResult = Int(audioResults.last?.highFrequencyAtMaxdB ?? -1)
                if latestResult > 0 {
                    unit.adjustsFontSizeToFitWidth = true
                    unit.text = "Hz"
                }
                else{
                    unit.text = self.emptyUnits
                }
                
            }
            
            if audioResults.count > 0 {
                last = audioResults.last?.timeRecorded ?? Date()
                cell.lastCheckupLabel.text = last.timeAgoDisplay()
            }else{
                cell.lastCheckupLabel.text = self.emptyUnits
            }
            
            
        }
        
        if indexPath.row == 1{
            
            let dataInterface:DataInterface = DataInterface()
            
            let visionResults = dataInterface.getPerceptibilityData()
            var percepScores:[Double] = []
            let x = Array(stride(from: 0, to: visionResults.count, by:1)).map {Double($0)}
            
            for visionRes in visionResults{
                percepScores.append(Double(visionRes.perceptibilityScore))
            }
            
            cell.loadSingleLineDataChart(xVals: x, yVals: percepScores, length: x.count)
            
            if visionResults.count > 0{
                cell.latestScoreCaption.isHidden = false
            }
            else{
                cell.latestScoreCaption.isHidden = true
            }
            
            for label in cell.latestScoreLabels {
                cell.latestScoreLabels.first?.adjustsFontSizeToFitWidth = true
                let latestResult = Int(visionResults.last?.perceptibilityScore ?? -1)
                var displayResult = String(latestResult)
                if latestResult == -1{
                    displayResult = self.emptyScore
                }
                label.text = displayResult
            }
            for unit in cell.scoreUnitsLabels {
                let latestResult = Int(visionResults.last?.perceptibilityScore ?? -1)
                if latestResult > 0 {
                    unit.adjustsFontSizeToFitWidth = true
                    unit.text = "Perceptibility"
                }
                else{
                    unit.text = self.emptyUnits
                }
            }
            
            if visionResults.count > 0 {
                last = visionResults.last?.timeRecorded ?? Date()
                cell.lastCheckupLabel.text = last.timeAgoDisplay()
            }else{
                cell.lastCheckupLabel.text = self.emptyUnits
            }
            
        }
        
        if indexPath.row == 2{
            
            let dataInterface:DataInterface = DataInterface()
            
            let tremorResults = dataInterface.getTremorData()
            var tremorMags:[Double] = []
            let x = Array(stride(from: 0, to: tremorResults.count, by:1)).map {Double($0)}
            
            for tremRes in tremorResults{
                tremorMags.append(Double(tremRes.tremorMagnitude))
            }
            
            cell.loadSingleLineDataChart(xVals: x, yVals: tremorMags, length: x.count)
            
            if tremorResults.count > 0{
                cell.latestScoreCaption.isHidden = false
            }
            else{
                cell.latestScoreCaption.isHidden = true
            }
            
            for label in cell.latestScoreLabels {
                cell.latestScoreLabels.first?.adjustsFontSizeToFitWidth = true
                let latestResult = tremorResults.last?.tremorMagnitude ?? -1
                var displayResult = String(format: "%.2f", latestResult)
                if latestResult == -1{
                    displayResult = self.emptyScore
                }
                label.text = displayResult
            }
            for unit in cell.scoreUnitsLabels {
                let latestResult = tremorResults.last?.tremorMagnitude ?? -1
                if latestResult > 0.0 {
                    unit.adjustsFontSizeToFitWidth = true
                    unit.text = "Tremor"
                }
                else{
                    unit.text = self.emptyUnits
                }
            }
            
            if tremorResults.count > 0 {
                last = tremorResults.last?.timeRecorded ?? Date()
                cell.lastCheckupLabel.text = last.timeAgoDisplay()
            }else{
                cell.lastCheckupLabel.text = self.emptyUnits
            }
            
        }
        
        
        
        cell.takeTestAction = {(cell) in
            if let parent = self.parent as? LandingPageController {
                parent.toView(viewName: self.cells[indexPath.row].lowercased())
            }
        }
        return cell
    }
    
    func computeNewDate(from fromDate: Date, to toDate: Date) -> Date  {
        let delta = toDate.timeIntervalSince(fromDate)
        print("Delta: \(delta)")
        let today = Date()
        if delta < 0 {
            return today
        }else {
            return today.addingTimeInterval(delta)
        }
    }
    

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell

        if cell.isAnimating() {
            return
        }

        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == Const.closeCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = Const.openCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = Const.closeCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            
            // fix https://github.com/Ramotion/folding-cell/issues/169
            if cell.frame.maxY > tableView.frame.maxY {
                tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }, completion: nil)
    }

}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
