//
//  Notification.swift
//  FullCast
//
//  Created by Vishwa  R on 20/02/22.
//

import Foundation

struct Notification {
    
    struct Details {
        let id: String
        let title: String
        let subtitle: String
        let body: String
        let notificationDate: Date
        var reminderDate: DateComponents {
            Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        }
    }
    
    func getNotificationDetails(_ body: String,_ id: UUID,_ reminderDate: Date) -> Notification.Details {
        return Notification.Details(id: "full_cast_remainder \(id.uuidString)", title: "FullCast", subtitle: "You got a remainder", body: "Remainder for the recording \(body)", notificationDate: reminderDate)
    }
    
}
