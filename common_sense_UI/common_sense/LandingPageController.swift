//
//  LandingPageController.swift
//  common_sense
//
//  Created by Matthew Lee on 12/11/20.
//

import UIKit

class LandingPageController: UIViewController {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var greetingText: UILabel!
    
    
    let dataInterface:DataInterface = DataInterface()
    
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        userName.text = defaults.string(forKey: "userName")
        greetingText.text = "Welcome"
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if defaults.bool(forKey: "firstLogin") == true{
            defaults.setValue(true, forKey: "firstLogin")
        }else{
            print("first")
            self.performSegue(withIdentifier: "createAccount", sender: nil)
            defaults.setValue(true, forKey: "firstLogin")
        }
        // Do any additional setup after loading the view.
    }
    
    func toView(viewName: String){
        self.performSegue(withIdentifier: viewName, sender: nil)
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
