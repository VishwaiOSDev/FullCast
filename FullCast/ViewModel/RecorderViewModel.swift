//
//  AudioRecorderViewModel.swift
//  FullCast
//
//  Created by Vishwa  R on 04/02/22.
//

import AVFoundation
import CoreData
import SwiftUI
import UserNotifications

final class RecorderViewModel : NSObject, ObservableObject {
    
    @Published var listOfRecordings : [Recorder.Details] = []
    @Published var recorderStatus: RecorderStatus = .stopRecorder
    @Published var showAlert = false
    private var recordings: [Recording] = []
    private(set) var audioIsPlaying = false
    private(set) var audioRecorder : AVAudioRecorder!
    private(set) var audioPlayer : AVAudioPlayer!
    private(set) var audioSession : AVAudioSession = AVAudioSession.sharedInstance() // Reuse this audioSession instead of recording session...
    private(set) var playingURL : URL?
    private(set) var recorderModel = Recorder()
    var timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
    func updateSlider() {
        guard let indexOfPlayingAudio = listOfRecordings.firstIndex(where: {$0.isPlaying == true}) else { return }
        listOfRecordings[indexOfPlayingAudio].elapsedDuration = audioPlayer.currentTime
        print("Current Duration \(audioPlayer.currentTime) :--: \(listOfRecordings[indexOfPlayingAudio].elapsedDuration)")
    }
    
    
    
    func setRemainderOfRecording(for id: UUID)  {
        let index = getIndexOfRecording(id)
        DispatchQueue.main.async {
            withAnimation {
                self.listOfRecordings[index].reminderEnabled = true
            }
        }
    }
    
    func cancelRemainder(for id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        let index = getIndexOfRecording(id)
        let coreDataStatus =  CoreDataController.shared.updateReminderForRecording(at: id, remainderType: .cancel)
        if coreDataStatus {
            DispatchQueue.main.async {
                withAnimation {
                    self.listOfRecordings[index].reminderEnabled = false
                }
            }
        } else {
            print("Failed to edit data in CoreData...")
        }
    }
}

extension RecorderViewModel {
    func startPlaying(id: UUID, sliderDuration : Double) {
        if audioIsPlaying {
            stopThePlayingAudio()
        }
        self.timer = timer.upstream.autoconnect()
        let indexOfRecording = getIndexOfRecording(id)
        listOfRecordings[indexOfRecording].isPlaying = true
        playingURL = listOfRecordings[indexOfRecording].audioURL
        audioIsPlaying = true
        do {
            audioPlayer = try AVAudioPlayer(contentsOf : playingURL!)
            audioPlayer.currentTime = Double(sliderDuration)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            print("The Audio is Playing...")
        } catch {
            print("Error start playing this audio \(error.localizedDescription)")
        }
    }
    
    func stopPlaying(id : UUID) {
        timer.upstream.connect().cancel()
        audioIsPlaying = false
        audioPlayer.stop()
        let index = getIndexOfRecording(id)
        listOfRecordings[index].isPlaying = false
    }
}

extension RecorderViewModel : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer.upstream.connect().cancel()
        audioIsPlaying = false
        guard let index = listOfRecordings.firstIndex(where: {$0.audioURL == player.url!}) else { return }
        listOfRecordings[index].isPlaying = false
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
    
    private func getIndexOfRecording(_ id: UUID) -> Array.Index {
        guard let index = listOfRecordings.firstIndex(where: {$0.id == id}) else { return -1 }
        return index
    }
    
    private func stopThePlayingAudio() {
        guard let indexOfPlayingAudio = listOfRecordings.firstIndex(where: {$0.isPlaying == true}) else { return }
        listOfRecordings[indexOfPlayingAudio].isPlaying = false
    }
}

//MARK: - Notification Section below is working fine.

extension RecorderViewModel: UNUserNotificationCenterDelegate {
    
    func requestAuthorization(for remainderDate: Date, with body: String, id: UUID) {
        UNUserNotificationCenter.current().delegate = self
        setupNotifcationManager(on: remainderDate, body: body, id: id)
    }
    
    private func setupNotifcationManager(on date: Date, body: String, id: UUID) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.getNotificationPermission { success in
                    guard success else { return }
                    self.scheduleNotifcation(for: date, with: body, id: id)
                }
            case .authorized:
                self.scheduleNotifcation(for: date, with: body, id: id)
            case .denied:
                break
            default:
                break
            }
        }
    }
    
    private func scheduleNotifcation(for remainderDate: Date, with body: String, id: UUID) {
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                title: "Play",
                                                options: [])
        let meetingInviteCategory =
        UNNotificationCategory(identifier: "PLAY_CATEGORY",
                               actions: [acceptAction],
                               intentIdentifiers: [],
                               hiddenPreviewsBodyPlaceholder: "",
                               options: .customDismissAction)
        UNUserNotificationCenter.current().setNotificationCategories([meetingInviteCategory])
        let content = UNMutableNotificationContent()
        content.title = "FullCast"
        content.subtitle = "You got an remainder"
        content.body = "Remainder for the recording \(body)"
        content.userInfo = ["AUDIO_ID": id.uuidString]
        content.categoryIdentifier = "PLAY_CATEGORY"
        let remainderDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: remainderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: remainderDateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "\(id.uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Error adding request to the calender: \(error.localizedDescription)")
            } else {
                let coreDataStatus = CoreDataController.shared.updateReminderForRecording(at: id, remainderType: .remind(remainderDate))
                if coreDataStatus {
                    self?.setRemainderOfRecording(for: id)
                } else {
                    print("Failed to store data in CoreData...")
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let idOfAudio = userInfo["AUDIO_ID"] as! String
        startPlaying(id: UUID(uuidString: idOfAudio)!, sliderDuration: 0.0)
        completionHandler()
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

//MARK: - Get List of Stored Audios MVVM Architecture...

extension RecorderViewModel {
    func getRecordings(of selectedCategory: Category) {
        DispatchQueue.main.async {
            withAnimation {
                self.listOfRecordings = self.recorderModel.getStoredRecording(selectedCategory)
            }
        }
    }
    
    func deleteRecordingOn(_ indexSet : IndexSet) {
        listOfRecordings.remove(atOffsets: indexSet)
        recorderModel.peformDeleteOfRecording(at: indexSet)
    }
}

//MARK: - Audio Recorder MVVM Architecture...

extension RecorderViewModel {
    func checkPermissionAndStartOrStopRecorder(for category: Category) {
        let fileName = "\(category.wrappedCategoryName) \(Date().toString(dateFormat: "dd, MMM YYYY 'at' HH:mm:ss")).m4a"
        RecorderService.shared.startRecording { result in
            switch(result) {
            case .success:
                self.startOrStopRecorder(for: fileName, on: category)
            case .failure(let error):
                self.recorderErrorHandling(error)
            }
        }
    }
    
    private func startOrStopRecorder(for fileName: String, on category: Category) {
        RecorderService.shared.recordAudio(fileName, on: category) { recorderStatus in
            switch recorderStatus {
            case .success(let recorder):
                DispatchQueue.main.async {
                    withAnimation {
                        self.recorderStatus = recorder
                        self.getRecordings(of: category)
                    }
                }
            case .failure(let errorMessage):
                // Handle Failures in here...
                print(errorMessage)
            }
        }
    }
    
    private func recorderErrorHandling(_ error: RecorderError) {
        switch error {
        case .permissionNotGranted:
            DispatchQueue.main.async {
                self.showAlert.toggle()
            }
        case .someOtherError(let errorMessage):
            print(errorMessage)
        }
    }
}

