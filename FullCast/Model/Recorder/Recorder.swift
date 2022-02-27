//
//  Recording.swift
//  FullCast
//
//  Created by Vishwa  R on 07/02/22.
//

import Foundation

struct Recorder {
    
    private var allRecordings: [Recording] = []
    
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
    
    mutating func getStoredRecording(_ category: Category) -> [Recorder.Details] {
        allRecordings = CoreDataController.shared.fetchAllRecordings(of: category) ?? []
        return PlayingService.shared.getDetailsOfEachRecording(on: category, recordingList: allRecordings)
    }
    
    func peformDeleteOfRecording(at indexSet: IndexSet) {
        indexSet.forEach { index in
            CoreDataController.shared.deleteRecording(recording: allRecordings[index])
        }
    }
}
