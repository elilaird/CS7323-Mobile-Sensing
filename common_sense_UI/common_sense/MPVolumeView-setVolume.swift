//
//  MPVolumeView-setVolume.swift
//  common_sense
//
//  Created by Eli Laird on 12/8/20.
//

import Foundation
import MediaPlayer

//This extension is based off of:
//https://stackoverflow.com/questions/33168497/ios-9-how-to-change-volume-programmatically-without-showing-system-sound-bar-po/50740234#50740234

extension MPVolumeView {
  static func setVolume(_ volume: Float) {
    let volumeView = MPVolumeView()
    let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
      slider?.value = volume
    }
  }
}
