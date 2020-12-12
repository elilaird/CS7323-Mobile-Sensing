//
//  AudioResultViewController.swift
//  common_sense
//
//  Created by Eli Laird on 12/12/20.
//

import UIKit

class AudioResultViewController: UIViewController {

    @IBOutlet weak var highestFrequency: UILabel!
    @IBOutlet weak var lowestFrequency: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var dataInterface: DataInterface = DataInterface()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let audioResults = dataInterface.getAudioData()

        self.highestFrequency.text = "Your Highest Frequency: " + self.getFormattedFrequency(with: audioResults.last!.highFrequencyAtMaxdB)
        self.lowestFrequency.text = "Your Lowest Frequency: " + self.getFormattedFrequency(with: audioResults.last!.lowFrequencyAtMaxdB)
        self.dateLabel.text = "Test Taken: " + self.getFormattedDate(with: audioResults.last!.timeRecorded)
        
  
    }
    
    func getFormattedFrequency(with freq:Float) -> String{
        let formatter = MeasurementFormatter()
        let hertz = Measurement(value: Double(freq), unit: UnitFrequency.hertz)
        return formatter.string(from: hertz)
    }
    
    func getFormattedDate(with date:Date) -> String{
        let formatter = DateFormatter()
        return formatter.string(from: date)
    }
    
    @IBAction func returnToLanding(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
    }

}
