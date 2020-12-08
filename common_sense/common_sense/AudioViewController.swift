//
//  AudioViewController.swift
//  common_sense
//
//  Created by Eli Laird on 12/8/20.
//

import UIKit
import MediaPlayer

let AUDIO_BUFFER_SIZE = 131072

class AudioViewController: UIViewController {

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    // setup audio model
    let audio = AudioModel(buffer_size: AUDIO_BUFFER_SIZE)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        MPVolumeView.setVolume(1.0)

        audio.startSinewaveProcessing(withFreq: 1000)
        audio.play()
    }
    
    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)

        audio.pause()
    }

    
    
    
}
