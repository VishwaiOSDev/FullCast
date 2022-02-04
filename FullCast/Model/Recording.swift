//
//  Recoding.swift
//  FullCast
//
//  Created by Vishwa  R on 04/02/22.
//

import Foundation

struct Recording : Identifiable {
    var id = UUID()
    let fileURL : URL
    var isPlaying : Bool = false
}
