//
//  AudioViewController-foundDbValues.swift
//  common_sense
//
//  Created by Eli Laird on 12/9/20.
//

import Foundation

extension AudioViewController {
    func foundDbValues(withMax max: Float, andHalf half: Float) {
        self.dbMax = max
        self.dbHalf = half
        self.audio.pause()
        self.waitLabel.isHidden = true
        print("Finished Calibrating...")
    }
}
