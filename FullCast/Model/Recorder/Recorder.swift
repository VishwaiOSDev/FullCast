//
//  Recording.swift
//  FullCast
//
//  Created by Vishwa  R on 07/02/22.
//

import Foundation
import AVFoundation

struct Recorder {
    
    struct Details : Identifiable {
        var id : UUID
        let fileName : String
        let audioURL : URL
        let createdAt : Date
        var isPlaying : Bool = false
        let duration : Double
        var elapsedDuration : Double
        var reminderDate: Date
        var reminderEnabled: Bool
        var showCalender: Bool = false
    }
    
    var player: AVAudioPlayer!
    
    mutating func fetchAllStoredRecordings(of selectedCategory: Category,_ recordings: [Recording] ) -> [Details]?  {
        let path = getPathOfDocumentDirectory()
        return detailsOf(recordings, in : path)
    }
    
    func saveFileToCoreData(of fileName : String, on category : Category) {
        let newRecording = Recording(context: CoreDataController.shared.viewContext)
        newRecording.id = UUID()
        newRecording.fileName = fileName
        newRecording.createdAt = Date()
        newRecording.toCategory = category
        CoreDataController.shared.save()
    }
    
    private mutating func detailsOf(_ recordings: [Recording], in path : String) -> [Details] {
        var recordingDetails = [Details]()
        for recording in recordings {
            let audioURL = URL(fileURLWithPath: path).appendingPathComponent(recording.fileName!)
            if let durationOfAudio = getDurationOfEachAudio(of: audioURL) {
                recordingDetails.append(Details(id: recording.id! , fileName : recording.fileName!, audioURL: audioURL, createdAt: recording.createdAt!, duration : durationOfAudio, elapsedDuration: 0.0, reminderDate: recording.whenToRemind ?? Date() , reminderEnabled: recording.reminderEnabled))
            }
        }
        return recordingDetails
    }
    
    private mutating func getDurationOfEachAudio(of url : URL) -> Double? {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            return player.duration
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func getPathOfDocumentDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
}
