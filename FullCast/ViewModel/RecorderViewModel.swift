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
    private var notificationModel = Notification()
    
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
        print("Current Duration \(audioPlayer.currentTime) :--: \(recordingsList[indexOfPlayingAudio].elapsedDuration)")
    }
    
    func deleteRecordingOn(_ indexSet : IndexSet) {
        recordingsList.remove(atOffsets: indexSet)
        indexSet.forEach { index in
            let recording = recordings[index]
            CoreDataController.shared.deleteRecording(recording: recording)
        }
    }
    
    func setRemainderOfRecording(for id: UUID)  {
        let index = getIndexOfRecording(id)
        DispatchQueue.main.async {
            withAnimation {
                self.recordingsList[index].reminderEnabled = true
            }
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
        self.timer = timer.upstream.autoconnect()
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
        let index = getIndexOfRecording(id)
        recordingsList[index].isPlaying = false
    }
    
}

extension RecorderViewModel : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer.upstream.connect().cancel()
        audioIsPlaying = false
        print("Playing URL \(playingURL!) and player \(player.url!)"  )
        guard let index = recordingsList.firstIndex(where: {$0.audioURL == player.url!}) else { return }
        recordingsList[index].isPlaying = false
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
        let fileName = "\(category.wrappedCategoryName) \(Date().toString(dateFormat: "dd, MMM YYYY 'at' HH:mm:ss")).m4a"
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


extension RecorderViewModel {
    
    func requestAuthorization(for remainderDate: Date, with body: String, id: UUID) {
        let notificationDetails = notificationModel.getNotificationDetails(body, id, remainderDate)
        setupNotifcationManager(with: notificationDetails)
    }
    
    private func setupNotifcationManager(with details: Notification.Details) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.getNotificationPermission { success in
                    guard success else { return }
                    self.scheduleNotifcation(for: details)
                }
            case .authorized:
                self.scheduleNotifcation(for: details)
            case .denied:
                self.showAlertMessage(
                    title: "Enable Notifications",
                    message: "To enable access, go to Settings > Privacy > Notifcation and turn on Notification access for this app."
                )
            default:
                self.showAlertMessage(
                    title: "Enable Notifications",
                    message: "To enable access, go to Settings > Privacy > Notifcation and turn on Notification access for this app."
                )
            }
        }
    }
    
    private func scheduleNotifcation(for details: Notification.Details) {
        let content = UNMutableNotificationContent()
        content.title = "\(details.title)"
        content.subtitle = "\(details.subtitle)"
        content.body = "Remainder for the recording \(details.body)"
        let trigger = UNCalendarNotificationTrigger(dateMatching: details.reminderDate, repeats: false)
        let request = UNNotificationRequest(identifier: "full_cast_remainder \(details.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Error adding request to the calender: \(error.localizedDescription)")
            } else {
                guard let notificationStatus = self?.notificationModel.saveNotificationToCoreDate(for: details) else { return }
                if notificationStatus {
                    self?.setRemainderOfRecording(for: details.id)
                } else {
                    print("Failed to Store Notification Details")
                }
            }
        }
    }
    
    private func getNotificationPermission(completionHandler: @escaping (_ success: Bool) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Error while getting notifcation permission \(error.localizedDescription)")
            }
            completionHandler(success)
        }
    }
}



