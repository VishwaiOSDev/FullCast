//
//  Constants.swift
//  FullCast
//
//  Created by Vishwa  R on 07/02/22.
//

import AVFoundation
import UIKit

enum MicrophoneAlertContent: String {
    case title = "Unable to access the Microphone"
    case message = "To enable access, go to Settings > Privacy > Microphone and turn on Microphone access for this app."
}

struct Constants {
    //    static let settings = [
    //        AVFormatIDKey: Int(kAudioFormatAppleLossless),
    //        AVSampleRateKey: 44100,
    //        AVNumberOfChannelsKey: 2,
    //        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
    //    ]
    static let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    static func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
