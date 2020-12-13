//
//  CreateAccountViewController.swift
//  common_sense
//
//  Created by Matthew Lee on 12/12/20.
//

import UIKit

class CreateAccountViewController: UIViewController {

    let defaults = UserDefaults.standard
    @IBOutlet weak var appDescription: UILabel!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDescription.alpha = 0
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func returnToLanding(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
    }


    
    @IBAction func confirmName(){
        defaults.setValue(firstName.text, forKey: "userName")
        UILabel.animate(withDuration: 1){
            self.appDescription.alpha = 1
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
