//
//  AccountCreationViewController.swift
//  common_sense
//
//  Created by Matthew Lee on 12/13/20.
//

import UIKit

class AccountCreationViewController: UIViewController {

    let defaults = UserDefaults.standard
    @IBOutlet weak var appDesc: UILabel!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastN: UITextField!
    @IBOutlet weak var getStarted: UIButton!
    
    var descriptionPart1: String = "Common Sense is about keeping in touch with your senses over time."
    var descriptionPart2: String = "Routine checkups let you see how your senses are changing and help you see when something is changing unexpectedly."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDesc.alpha = 0
        self.appDesc.text = descriptionPart1
        self.getStarted.alpha = 0
        self.getStarted.isEnabled = false
        
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func returnToLanding(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
    }


    
    @IBAction func confirmName(){
        dismissKeyboard()
        defaults.setValue(firstName.text, forKey: "userName")
        UILabel.animate(withDuration: 1){
            self.appDesc.alpha = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            UILabel.animate(withDuration: 1){
                self.appDesc.alpha = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.appDesc.text = self.descriptionPart2
            UILabel.animate(withDuration: 1){
                self.appDesc.alpha = 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            UILabel.animate(withDuration: 1){
                self.appDesc.alpha = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 13.0) { // Change `2.0` to the desired number of seconds.
            self.getStarted.isEnabled = true
            UIButton.animate(withDuration: 1){
                self.getStarted.alpha = 1
            }
        }
    
        
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
