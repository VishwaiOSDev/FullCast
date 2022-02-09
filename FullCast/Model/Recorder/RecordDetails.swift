//
//  Recoding.swift
//  FullCast
//
//  Created by Vishwa  R on 04/02/22.
//

import Foundation

struct RecordDetails : Identifiable {
    var id : UUID
    var fileName : String
    var audioURL : URL
    var createdAt : Date
    var isPlaying : Bool = false
    var duration : Float = 0.0
    var elapsedDuration : Float = 0.0
}
