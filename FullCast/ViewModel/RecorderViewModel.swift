//
//  AudioRecorderViewModel.swift
//  FullCast
//
//  Created by Vishwa  R on 04/02/22.
//

import AVFoundation
import CoreData
import SwiftUI

final class RecorderViewModel : NSObject, ObservableObject {
    
    @Published var isRecording = false
    @Published var recordingsList : [RecordDetails] = []
    @Published var showAlert = false
    @Published var alertDetails : AlertDetails?
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var playingURL : URL?
    private var model = Recorder()
    
    func getStoredRecordings() {
        guard let recordings = model.fetchAllStoredRecordings() else { return }
        DispatchQueue.main.async {
            self.recordingsList = recordings
        }
    }
    
    func showAlertMessage(title : String, message: String) {
        let alert = AlertDetails(alertTitle: title, alertMessage: message)
        DispatchQueue.main.async {
            self.showAlert = true
            self.alertDetails = alert
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

extension RecorderViewModel : Recordable {
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Cannot setup recording \(error.localizedDescription)")
        }
        switch(recordingSession.recordPermission) {
        case .undetermined:
            showAlertMessage(title: "Unable to access the Microphone", message: "To enable access, go to Settings > Privacy > Microphone and turn on Microphone access for this app.")
        case .denied:
            showAlertMessage(title: "Unable to access the Microphone", message: "To enable access, go to Settings > Privacy > Microphone and turn on Microphone access for this app.")
        case .granted:
            let newRecording = Recording(context: CoreDataController.shared.viewContext)
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
        @unknown default:
            fatalError("Apple has introduced something new.")
        }
    }
    
    func stopRecording(){
        audioRecorder.stop()
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
}

extension RecorderViewModel : Playable {
    func startPlaying(url : URL) {
        playingURL = url
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

extension RecorderViewModel : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        for i in 0..<recordingsList.count {
            if recordingsList[i].audioURL == playingURL {
                recordingsList[i].isPlaying = false
            }
        }
    }
}

