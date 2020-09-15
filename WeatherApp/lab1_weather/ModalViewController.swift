//
//  ModalViewController.swift
//  lab1_weather
//
//  Created by Matthew on 9/7/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    
    @IBAction func ReturnFromSettings(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
