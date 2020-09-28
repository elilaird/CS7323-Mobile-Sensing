//
//  DopplerViewController.swift
//  AudioLabSwift
//
//  Created by Matthew Lee on 9/27/20.
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit

class DopplerViewController: UIViewController {
    
    let audio = AudioModel(buffer_size: 1024*4)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        audio.startSinewaveProcessing(withFreq: 15000)
        audio.play()
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        audio.pause()
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
