//
//  RecordingCell.swift
//  FullCast
//
//  Created by Vishwa  R on 08/02/22.
//

import SwiftUI

struct RecordingCell : View {
    
    @Binding var record : RecordDetails
    @ObservedObject var recorderViewModel : RecorderViewModel
    var action : () -> ()
    
    var body : some View {
        VStack {
            HStack {
                Image(systemName : "headphones.circle.fill")
                    .font(.title)
                Text(record.fileName)
            }
            Slider(value: $record.elapsedDuration, in: 0...Float(record.duration), onEditingChanged: { didChanged in
                if didChanged {
                    recorderViewModel.stopPlaying(url: record.audioURL)
                } else {
                    recorderViewModel.startPlaying(url: record.audioURL, sliderDuration: record.elapsedDuration)
                }
            })
                .accentColor(Color(UIColor(.yellow)))
                .padding(.vertical, 4)
            Button(action: action) {
                Image(systemName: record.isPlaying ? "stop.fill" : "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size:30))
            }
        }
        .padding()
        .frame(maxWidth : .infinity)
        .background(Color(UIColor(red: 0.34, green: 0.34, blue: 0.34, alpha: 1.00)))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
}

