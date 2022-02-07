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
    
    @Published var recordingsList : [RecordDetails] = []
    @Published var isRecording = false
    @Published var showAlert = false
    @Published var alertDetails : AlertDetails?
    private(set) var recorderModel = Recorder()
    private(set) var audioRecorder : AVAudioRecorder!
    private(set) var audioPlayer : AVAudioPlayer!
    private(set) var playingURL : URL?
    
    func getStoredRecordings() {
        guard let recordings = recorderModel.fetchAllStoredRecordings() else { return }
        DispatchQueue.main.async {
            self.recordingsList = recordings
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func showAlertMessage(title : String, message: String) {
        let alert = AlertDetails(alertTitle: title, alertMessage: message)
        DispatchQueue.main.async {
            self.showAlert = true
            self.alertDetails = alert
        }
    }
}

extension RecorderViewModel : Recordable {
    func startRecording() {
        let microphonePermission = setupRecordingSession()
        switch(microphonePermission) {
        case .undetermined:
            showAlertMessage(
                title: "Unable to access the Microphone",
                message: "To enable access, go to Settings > Privacy > Microphone and turn on Microphone access for this app."
            )
        case .denied:
            showAlertMessage(
                title: "Unable to access the Microphone",
                message: "To enable access, go to Settings > Privacy > Microphone and turn on Microphone access for this app."
            )
        case .granted:
            recordAudio()
        @unknown default:
            fatalError("Apple has introduced something new.")
        }
    }
    
    private func recordAudio() {
        let fileName = "FullCast: \(Date().toString(dateFormat: "dd, MMM YYYY 'at' HH:mm:ss")).m4a"
        let path = URL.documents.appendingPathComponent(fileName)
        do {
            audioRecorder = try AVAudioRecorder(url: path, settings: Constants.settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            recorderModel.saveFileToCoreData(fileName)
            DispatchQueue.main.async {
                self.isRecording = true
            }
        } catch {
            fatalError("Failed to play the recording \(error.localizedDescription)")
        }
    }
    
    func stopRecording(){
        audioRecorder.stop()
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
    
    private func setupRecordingSession() -> AVAudioSession.RecordPermission {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Cannot setup recording \(error.localizedDescription)")
        }
        return recordingSession.recordPermission
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

