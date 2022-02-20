//
//  RecordingCell.swift
//  FullCast
//
//  Created by Vishwa  R on 08/02/22.
//

import SwiftUI
import UserNotifications

struct RecordingCell : View {
    
    @Binding var record : RecordDetails
    @ObservedObject var recorderViewModel : RecorderViewModel
    @EnvironmentObject var notificationViewModel: NotifcationViewModel
    var action : () -> ()
    
    var body : some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(record.fileName.dropLast(29)))
                    Text(record.createdAt.toString(dateFormat: "dd-MMM-YYYY"))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack {
                    HStack {
                        Button(action : openCalender) {
                            Image(systemName: record.reminderEnabled ? "calendar.badge.clock" : "calendar")
                                .font(.title2)
                                .foregroundColor(Color(UIColor.systemYellow))
                        }
                        Button(action: openActionSheet) {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                                .foregroundColor(Color(UIColor.systemYellow))
                        }
                    }
                }
            }
            controller
        }
        .alert(isPresented: $notificationViewModel.showNotificationAlert) {
            guard let alertDetails = notificationViewModel.alertDetails else { fatalError("Failed to load alert details") }
            return Alert(
                title: Text(alertDetails.alertTitle),
                message: Text(alertDetails.alertMessage),
                primaryButton: .cancel(Text("Cancel")),
                secondaryButton: .default(Text("Settings"), action: Constants.openSettings)
            )
        }
        .frame(maxHeight: 150)
        .padding(.vertical, 4)
    }
    
    private var controller : some View {
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
                    DatePicker("Set remainder:",selection: $record.reminderData, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .font(.subheadline)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    Spacer()
                    Button(action: setRemainder) {
                        Text("Done")
                            .foregroundColor(Color(UIColor.systemYellow))
                            .bold()
                    }
                }
            }
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
        notificationViewModel.requestAuthorization(for: record.reminderData, with: String(record.fileName.dropLast(4)), id: record.id)
    }
    
    private var playStopButton : some View {
        Button(action: action) {
            Image(systemName: record.isPlaying ? "pause.circle" : "play.circle")
                .foregroundColor(.white)
                .font(.system(size:30))
        }
    }
    
    private func openCalender() {
        withAnimation {
            record.showCalender.toggle()
        }
    }
    
    private func openActionSheet() {
        let activityVC = UIActivityViewController(activityItems: [record.audioURL], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        return String(format: "%02i:%02i", minute, second)
    }
}


struct RecordingCell_Previews : PreviewProvider {
    static var previews: some View {
        RecordingCell(record: .constant(RecordDetails(id: UUID(), fileName: "iOS Dev", audioURL: URL(fileURLWithPath: "url"), createdAt: Date(), duration: 1.0, elapsedDuration: 0.3, reminderData: Date(), reminderEnabled: true)), recorderViewModel: RecorderViewModel()) {
        }
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        .environmentObject(NotifcationViewModel())
    }
}
