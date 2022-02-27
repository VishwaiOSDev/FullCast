//
//  Recording.swift
//  FullCast
//
//  Created by Vishwa  R on 07/02/22.
//

import Foundation

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
    
    func getStoredRecording(_ category: Category) -> [Recorder.Details] {
        let allRecording = CoreDataController.shared.fetchAllRecordings(of: category) ?? []
        return PlayingService.shared.getDetailsOfEachRecording(on: category, recordingList: allRecording)
    }
    
}
