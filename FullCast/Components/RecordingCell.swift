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
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.fileName)
                    Text(record.createdAt.toString(dateFormat: "dd-MMM-YYYY"))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: openActionSheet) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(Color(UIColor.systemYellow))
                }
            }
            controller
        }
        .padding(.vertical, 4)
    }
    
    private func openActionSheet() {
        let activityVC = UIActivityViewController(activityItems: [record.audioURL], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    private var controller : some View {
        ZStack {
            Capsule()
                .foregroundColor(Color(UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.00)))
            HStack(alignment: .center, spacing: 6) {
                playStopButton
                slider
                    .accentColor(Color(UIColor(.yellow)))
                    .padding(.vertical, 4)
                durationView
            }.padding(8)
        }
    }
    
    private var playStopButton : some View {
        Button(action: action) {
            Image(systemName: record.isPlaying ? "stop.circle" : "play.circle")
                .foregroundColor(.white)
                .font(.system(size:30))
        }
    }
    
    private var slider : some View {
        Slider(value: $record.elapsedDuration, in: 0.0...record.duration, onEditingChanged: { didChanged in
            if didChanged {
                if recorderViewModel.audioIsPlaying {
                    recorderViewModel.stopPlaying(id: record.id)
                }
            }
        })
    }
    
    private var durationView : some View {
        Text("\(timeString(time:TimeInterval(record.elapsedDuration)))")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 4)
            .frame(width: 55)
    }
    
    func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        return String(format: "%02i:%02i", minute, second)
    }
}
