//
//  ViewController.swift
//  common_sense
//
//  Created by Clay Harper on 12/2/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let di = DataInterface()
        di.saveTremorData(tremorMagnitude: 5.0)
        di.saveTremorData(tremorMagnitude: 8.0)
        let data = di.getTremorData()
        let elem = data[0]
        
        print("Got saved value of \(elem.tremorMagnitude) at time \(elem.timeRecorded)")
    }


}

