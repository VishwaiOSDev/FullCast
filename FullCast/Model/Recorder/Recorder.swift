//
//  Recording.swift
//  FullCast
//
//  Created by Vishwa  R on 07/02/22.
//

import Foundation

struct Recorder {
    
    func fetchAllStoredRecordings(of selectedCategory: Category) -> [RecordDetails]?  {
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
