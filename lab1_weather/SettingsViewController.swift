//
//  SettingsViewController.swift
//  lab1_weather
//
//  Created by Matthew on 9/11/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

import UIKit

protocol settingsDelegateProtocol {
    func saveSettings(fontSize: Int, metric: Bool, daysToDisplay: Int)
}

class SettingsViewController: UIViewController {
    
    var delegate: settingsDelegateProtocol? = nil
    var fontSize: Int! = nil
    var isMetric: Bool! = nil
    var daysToDisplay: Int! = nil

    @IBOutlet weak var fontSlider: UISlider!
    @IBOutlet weak var tempSwitch: UISwitch!
    @IBOutlet weak var dayStepper: UIStepper!
    @IBOutlet weak var daysDisplay: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.dayStepper.value = 10
        self.dayStepper.maximumValue = 15
        self.dayStepper.minimumValue = 5
        self.daysDisplay.text = Int(self.dayStepper.value).description
    }
    
    @IBAction func stepperValueChange(_ sender: UIStepper) {
        self.daysDisplay.text = Int(sender.value).description
    }
    
    
    @IBAction func saveAndDismiss(_ sender: UIButton) {
        if self.delegate != nil  {
            let font = Int(self.fontSlider.value)
            let metric = self.tempSwitch.isOn
            let days = Int(self.dayStepper.value)
            print(font,metric,days)
            self.delegate?.saveSettings(fontSize: font, metric: metric, daysToDisplay: days)
        }
        dismiss(animated: true, completion: nil)
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
