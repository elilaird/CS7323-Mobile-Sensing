//
//  AudioResultViewController.swift
//  common_sense
//
//  Created by Eli Laird on 12/12/20.
//

import UIKit

class AudioResultViewController: UIViewController {


    @IBOutlet weak var hearingRange: UILabel!
    
    var dataInterface: DataInterface = DataInterface()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let audioResults = dataInterface.getAudioData()
        let high = getFormattedFrequency(with: audioResults.last!.highFrequencyAtMaxdB)
        let low = getFormattedFrequency(with: audioResults.last!.lowFrequencyAtMaxdB)

        self.hearingRange.adjustsFontSizeToFitWidth = true
        self.hearingRange.text = String(format: "%@ - %@", low, high)

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
