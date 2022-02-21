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
    var action: () -> ()
    
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
            Controller(record: $record, recorderViewModel: recorderViewModel, action: action)
        }
        .frame(maxHeight: 150)
        .padding(.vertical, 4)
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
}


struct RecordingCell_Previews : PreviewProvider {
    static var previews: some View {
        RecordingCell(record: .constant(RecordDetails(id: UUID(), fileName: "iOS Dev", audioURL: URL(fileURLWithPath: "url"), createdAt: Date(), duration: 1.0, elapsedDuration: 0.3, reminderDate: Date(), reminderEnabled: true)), recorderViewModel: RecorderViewModel()) {
        }
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
