//
//  AudioRecorderViewModel.swift
//  FullCast
//
//  Created by Vishwa  R on 04/02/22.
//

import AVFoundation
import CoreData
import SwiftUI

protocol Recordable {
    func startRecording(on category : Category)
    func stopRecording()
}

protocol Playable {
    func startPlaying(id: UUID, sliderDuration: Double)
    func stopPlaying(id : UUID)
}

final class RecorderViewModel : NSObject, ObservableObject {
    
    @Published var recordingsList : [RecordDetails] = [] {
        didSet {
            guard let safeRecording = CoreDataController.shared.fetchAllRecordings(of: selectedCategory) else { return }
            recordings = safeRecording
        }
    }
    @Published var isRecording = false
    @Published var showAlert = false
    @Published var alertDetails : AlertDetails?
    private var recordings: [Recording] = []
    private(set) var selectedCategory: Category!
    private(set) var audioIsPlaying = false
    private(set) var recorderModel = Recorder()
    private(set) var audioRecorder : AVAudioRecorder!
    private(set) var audioPlayer : AVAudioPlayer!
    private(set) var audioSession : AVAudioSession = AVAudioSession.sharedInstance() // Reuse this audioSession instead of recording session...
    private(set) var playingURL : URL?
    var timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
    
    func getStoredRecordings(for selectedCategory: Category) {
        self.selectedCategory = selectedCategory
        guard let recordings = recorderModel.fetchAllStoredRecordings(of: selectedCategory) else { return }
        DispatchQueue.main.async {
            self.recordingsList = recordings
        }
    }
    
    func updateSlider() {
        guard let indexOfPlayingAudio = recordingsList.firstIndex(where: {$0.isPlaying == true}) else { return }
        recordingsList[indexOfPlayingAudio].elapsedDuration = audioPlayer.currentTime
        print("Elasped Time: ", audioPlayer.currentTime)
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func deleteRecordingOn(_ indexSet : IndexSet) {
        recordingsList.remove(atOffsets: indexSet)
        indexSet.forEach { index in
            let recording = recordings[index]
            CoreDataController.shared.deleteRecording(recording: recording)
        }
    }
}

extension RecorderViewModel : Recordable {
    func startRecording(on category : Category) {
        let microphonePermission = setupRecordingSession()
        switch(microphonePermission) {
        case .undetermined:
            audioSession.requestRecordPermission { permission in
                if !permission {
                    return self.showAlertMessage(
                        title: "Unable to access the Microphone",
                        message: "To enable access, go to Settings > Privacy > Microphone and turn on Microphone access for this app."
                    )
                }
                self.startRecording(on: category)
            }
        case .denied:
            showAlertMessage(
                title: "Unable to access the Microphone",
                message: "To enable access, go to Settings > Privacy > Microphone and turn on Microphone access for this app."
            )
        case .granted:
            recordAudio(on: category)
        @unknown default:
            fatalError("Apple has introduced something new.")
        }
    }
    
    func stopRecording(){
        audioRecorder.stop()
        DispatchQueue.main.async {
            withAnimation {
                self.isRecording = false
            }
        }
    }
}

extension RecorderViewModel : Playable {
    func startPlaying(id: UUID, sliderDuration : Double) {
        if audioIsPlaying {
            stopThePlayingAudio()
        }
        self.timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
        let indexOfRecording = getIndexOfRecording(id)
        recordingsList[indexOfRecording].isPlaying = true
        playingURL = recordingsList[indexOfRecording].audioURL
        audioIsPlaying = true
        do {
            audioPlayer = try AVAudioPlayer(contentsOf : playingURL!)
            audioPlayer.currentTime = Double(sliderDuration)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("Error start playing this audio \(error.localizedDescription)")
        }
    }
    
    func stopPlaying(id : UUID) {
        timer.upstream.connect().cancel()
        audioIsPlaying = false
        audioPlayer.stop()
        for i in recordingsList.indices {
            if recordingsList[i].audioURL == playingURL {
                recordingsList[i].isPlaying = false
                break
            }
        }
    }
    
}

extension RecorderViewModel : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioIsPlaying = false
        for i in recordingsList.indices {
            if recordingsList[i].audioURL == playingURL {
                recordingsList[i].isPlaying = false
                break
            }
        }
    }
}

extension RecorderViewModel {
    private func setupRecordingSession() -> AVAudioSession.RecordPermission {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord , mode: .default, options: [.defaultToSpeaker])
            try recordingSession.setActive(true)
        } catch {
            print("Cannot setup recording \(error.localizedDescription)")
        }
        return recordingSession.recordPermission
    }
    
    private func recordAudio(on category : Category) {
        let fileName = "FullCast: \(Date().toString(dateFormat: "dd, MMM YYYY 'at' HH:mm:ss")).m4a"
        let path = URL.documents.appendingPathComponent(fileName)
        do {
            audioRecorder = try AVAudioRecorder(url: path, settings: Constants.settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            recorderModel.saveFileToCoreData(of: fileName,on: category)
            DispatchQueue.main.async {
                withAnimation {
                    self.isRecording = true
                }
            }
        } catch {
            fatalError("Failed to play the recording \(error.localizedDescription)")
        }
    }
    
    private func getIndexOfRecording(_ id: UUID) -> Array.Index {
        guard let index = recordingsList.firstIndex(where: {$0.id == id}) else { return -1 }
        return index
    }
    
    private func showAlertMessage(title : String, message: String) {
        let alert = AlertDetails(alertTitle: title, alertMessage: message)
        DispatchQueue.main.async {
            self.showAlert = true
            self.alertDetails = alert
        }
    }
    
    private func stopThePlayingAudio() {
        guard let indexOfPlayingAudio = recordingsList.firstIndex(where: {$0.isPlaying == true}) else { return }
        recordingsList[indexOfPlayingAudio].isPlaying = false
    }
}



