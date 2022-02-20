//
//  Recoding.swift
//  FullCast
//
//  Created by Vishwa  R on 04/02/22.
//

import Foundation

struct RecordDetails : Identifiable {
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


