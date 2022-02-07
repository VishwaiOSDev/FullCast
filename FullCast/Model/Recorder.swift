//
//  Recording.swift
//  FullCast
//
//  Created by Vishwa  R on 07/02/22.
//

import Foundation

protocol Recordable {
    func startRecording()
    func stopRecording()
}

protocol Playable {
    func startPlaying(url : URL)
    func stopPlaying(url : URL)
}

struct Recorder {
    
    func fetchAllStoredRecordings() -> [RecordDetails]?  {
        guard let recordings = CoreDataController.shared.fetchAllRecordings() else { return nil }
        let path = getPathOfDocumentDirectory()
        return detailsOf(recordings, in : path)
    }
    
    func saveFileToCoreData(_ fileName : String) {
        let newRecording = Recording(context: CoreDataController.shared.viewContext)
        newRecording.id = UUID()
        newRecording.fileName = fileName
        newRecording.createdAt = Date()
        CoreDataController.shared.save()
    }
    
    private func detailsOf(_ recordings: [Recording], in path : String) -> [RecordDetails] {
        var recordingDetails = [RecordDetails]()
        for recording in recordings {
            let audioURL = URL(fileURLWithPath: path).appendingPathComponent(recording.fileName!)
            recordingDetails.append(RecordDetails(id: recording.id! , fileName : recording.fileName!, audioURL: audioURL, createdAt: recording.createdAt!))
        }
        return recordingDetails
    }
    
    private func getPathOfDocumentDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
}
