//
//  Constants.swift
//  FullCast
//
//  Created by Vishwa  R on 07/02/22.
//

import AVFoundation

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
}
