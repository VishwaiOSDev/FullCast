//
//  AudioRecorderViewModel.swift
//  FullCast
//
//  Created by Vishwa  R on 04/02/22.
//

import AVFoundation
import SwiftUI
import CoreData

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
    @Published var recordingsList : [RecordingModel] = []
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var playingURL : URL?
    
    func fetchAllRecoding() {
        var myRecordings = [RecordingModel]()
        guard let recordings = CoreDataController.shared.fetchAllRecordings() else { return }
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        for recording in recordings {
            let audioURL = URL(fileURLWithPath: path).appendingPathComponent(recording.fileName!)
            myRecordings.append(RecordingModel(id: recording.id! , fileName : recording.fileName!, audioURL: audioURL, createdAt: recording.createdAt!, isPlaying: false))
        }
        DispatchQueue.main.async {
            self.recordingsList = myRecordings
        }
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
            let newRecording = Recording(context: CoreDataController.shared.viewContext)
            if permissionGranted {
                let fileName = "FullCast: \(Date().toString(dateFormat: "dd, MMM YYYY 'at' HH:mm:ss")).m4a"
                let path = URL.documents.appendingPathComponent(fileName)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                do {
                    self.audioRecorder = try AVAudioRecorder(url: path, settings: settings)
                    self.audioRecorder.prepareToRecord()
                    self.audioRecorder.record()
                    newRecording.id = UUID()
                    newRecording.fileName = fileName
                    newRecording.createdAt = Date()
                    CoreDataController.shared.save()
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
            for i in 0..<recordingsList.count {
                if recordingsList[i].audioURL == playingURL {
                    recordingsList[i].isPlaying = true
                }
            }
        } catch {
            print("Error start playing this audio \(error.localizedDescription)")
        }
    }
    
    func stopPlaying(url : URL) {
        audioPlayer.stop()
        for i in 0..<recordingsList.count {
            if recordingsList[i].audioURL == playingURL {
                recordingsList[i].isPlaying = false
            }
        }
        audioPlayer.currentTime = 0
    }
}

extension AudioRecorderViewModel : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        for i in 0..<recordingsList.count {
            if recordingsList[i].audioURL == playingURL {
                recordingsList[i].isPlaying = false
            }
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
