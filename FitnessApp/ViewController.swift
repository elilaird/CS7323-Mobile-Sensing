//
//  ViewController.swift
//  FitnessApp
//
//  Created by Eli Laird on 10/12/20.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var circularProgress: CircularProgressView!
 

    override func viewDidLoad() {
        super.viewDidLoad()
        circularProgress.trackClr = UIColor.cyan
        circularProgress.progressClr = UIColor.purple
    }

    @IBAction func btn95(_ sender: Any) {
          circularProgress.setProgressWithAnimation(duration: 1.0, value: 0.95)
       }
       @IBAction func btn30(_ sender: Any) {
          circularProgress.setProgressWithAnimation(duration: 1.0, value: 0.30)
       }
       @IBAction func btn60(_ sender: Any) {
          circularProgress.setProgressWithAnimation(duration: 1.0, value: 0.60)
       }

}

