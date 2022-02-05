//
//  AudioRecorderViewModel.swift
//  FullCast
//
//  Created by Vishwa  R on 04/02/22.
//

import AVFoundation
import SwiftUI

protocol Recordable {
    func startRecording()
    func stopRecording()
}

protocol Playable {
    func startPlaying(url : URL)
    func stopPlaying(url : URL)
}

final class AudioRecorderViewModel : NSObject, ObservableObject {
    
    @Published var isRecording = false
    @Published var recordingsList = [Recording]()
    
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var playingURL : URL?
    
    func fetchAllRecoding() {
        recordingsList = []
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: URL.documents, includingPropertiesForKeys: nil)
            for item in directoryContents {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: item)
                    recordingsList.append(Recording(fileURL: item, duration: audioPlayer.duration.stringFromTimeInterval()))
                } catch {
                    print(error.localizedDescription)
                }
            }
            print(recordingsList)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

extension AudioRecorderViewModel : Playable {
    func startPlaying(url : URL) {
        playingURL = url
        let playSession = AVAudioSession.sharedInstance()
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in device")
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf : url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            for index in 0..<recordingsList.count {
                if recordingsList[index].fileURL == url {
                    recordingsList[index].isPlaying = true
                }
            }
        } catch {
            print("Error start playing this audio \(error.localizedDescription)")
        }
    }
    
    func stopPlaying(url : URL) {
        audioPlayer.stop()
        for index in 0..<recordingsList.count {
            if recordingsList[index].fileURL == url {
                recordingsList[index].isPlaying = false
            }
        }
        audioPlayer.currentTime = 0
    }
}

extension AudioRecorderViewModel : Recordable {
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Cannot setup recording \(error.localizedDescription)")
        }
        recordingSession.requestRecordPermission { permissionGranted in
            if permissionGranted {
                let path = URL.documents
                let fileName = path.appendingPathComponent("FullCast: \(Date().toString(dateFormat: "dd, MMM YYYY 'at' HH:mm:ss")).m4a")
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                do {
                    self.audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                    self.audioRecorder.prepareToRecord()
                    self.audioRecorder.record()
                    DispatchQueue.main.async {
                        self.isRecording = true
                    }
                } catch {
                    print("Failed to Setup the Recording")
                }
            } else {
                print("Show Alert...")
            }
        }
    }
    
    func stopRecording(){
        audioRecorder.stop()
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
}

extension AudioRecorderViewModel : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        for i in 0..<recordingsList.count {
            if recordingsList[i].fileURL == playingURL {
                recordingsList[i].isPlaying = false
            }
        }
    }
}

extension TimeInterval{
    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        var formatString = ""
        if hours == 0 {
            if(minutes < 10) {
                formatString = "%2d:%0.2d"
            }else {
                formatString = "%0.2d:%0.2d"
            }
            return String(format: formatString,minutes,seconds)
        }else {
            formatString = "%2d:%0.2d:%0.2d"
            return String(format: formatString,hours,minutes,seconds)
        }
    }
}

extension Date {
    func toString( dateFormat format  : String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension URL {
    static var documents : URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
