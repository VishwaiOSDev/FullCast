//
//  Controller.swift
//  FullCast
//
//  Created by Vishwa  R on 20/02/22.
//

import SwiftUI

struct Controller: View {
    
    func didNotificationAddedToDatabase(id: UUID) {
        print("This is the ID \(id)")
    }
    
    @Binding var record: RecordDetails
    @ObservedObject var recorderViewModel: RecorderViewModel
//    @EnvironmentObject var notificationViewModel: NotifcationViewModel
    var action: () -> ()
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: record.showCalender ? 30 : 12)
                    .foregroundColor(Color(UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.00)))
                HStack(alignment: .center, spacing: 6) {
                    playStopButton
                    slider
                        .accentColor(Color(UIColor(.yellow)))
                        .padding(.vertical, 4)
                    durationView
                }.padding(8)
            }
            if record.showCalender {
                HStack {
                    DatePicker("Set remainder:",selection: $record.reminderDate , in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .font(.subheadline)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    Spacer()
                    if record.reminderEnabled {
                        Button(action: cancelRemainder) {
                            Text("Cancel")
                        }
                    }
                    Button(action: setRemainder) {
                        Text("Done")
                            .foregroundColor(Color(UIColor.systemYellow))
                            .bold()
                    }
                }
            }
        }
        .alert(isPresented: $recorderViewModel.showAlert) {
            guard let alertDetails = recorderViewModel.alertDetails else { fatalError("Failed to load alert details") }
            return Alert(
                title: Text(alertDetails.alertTitle),
                message: Text(alertDetails.alertMessage),
                primaryButton: .cancel(Text("Cancel")),
                secondaryButton: .default(Text("Settings"), action: Constants.openSettings)
            )
        }
    }
    
    private var playStopButton : some View {
        Button(action: action) {
            Image(systemName: record.isPlaying ? "pause.circle" : "play.circle")
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
    
    private func setRemainder() {
        recorderViewModel.requestAuthorization(for: record.reminderDate, with: String(record.fileName.dropLast(4)), id: record.id)
    }
    
    private func cancelRemainder() {
        
    }
    
    func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        return String(format: "%02i:%02i", minute, second)
    }
}
