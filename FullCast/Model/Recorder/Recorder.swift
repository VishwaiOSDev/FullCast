//
//  Recording.swift
//  FullCast
//
//  Created by Vishwa  R on 07/02/22.
//

import Foundation
import AVFoundation

struct Recorder {
    
    var player: AVAudioPlayer!
    
    mutating func fetchAllStoredRecordings(of selectedCategory: Category) -> [RecordDetails]?  {
        guard let recordings = CoreDataController.shared.fetchAllRecordings(of: selectedCategory) else { return nil }
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
    
    private mutating func detailsOf(_ recordings: [Recording], in path : String) -> [RecordDetails] {
        var recordingDetails = [RecordDetails]()
        for recording in recordings {
            let audioURL = URL(fileURLWithPath: path).appendingPathComponent(recording.fileName!)
            if let durationOfAudio = getDurationOfEachAudio(of: audioURL) {
                recordingDetails.append(RecordDetails(id: recording.id! , fileName : recording.fileName!, audioURL: audioURL, createdAt: recording.createdAt!, duration : durationOfAudio, elapsedDuration: 0.0))
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
