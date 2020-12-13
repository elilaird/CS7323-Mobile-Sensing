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

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.view.backgroundColor = UIColor(named: "red")
        
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
            //loadSingleLineDataChart(xVals: , // x values array
            //                        yVals: , // y values array
            //                        length: ) // number of data points
        }else{ // Call 1 line graph for others
            //loadDoubleLineDataChart(xValsLow: [Double], // lower bound x vals
            //                        yValsLow: [Double], // lower bound y vals
            //                        xValsHigh: [Double], // upper bound x vals
            //                        yValsHigh: [Double], // upper bound y vals
            //                        length: Int) // number of data points
        }
        
        
        cell.takeTestAction = {(cell) in
            if let parent = self.parent as? LandingPageController {
                parent.toView(viewName: self.cells[indexPath.row].lowercased())
            }
        }
        return cell
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
