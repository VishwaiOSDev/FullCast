//
//  NotificationViewModel.swift
//  FullCast
//
//  Created by Vishwa  R on 18/02/22.
//

import Foundation
import UserNotifications
import SwiftUI

final class NotifcationViewModel: ObservableObject {
    
    @Published private(set) var notifications: [UNNotificationRequest] = []
    @Published private(set) var showDatePicker: Bool = false
    @Published var showNotificationAlert = false
    @Published var alertDetails : AlertDetails?
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.getNotificationPermission()
            case .authorized:
                DispatchQueue.main.async {
                    withAnimation {
                        self.showDatePicker.toggle()
                    }
                }
                break
            case .denied:
                self.showAlertMessage(
                    title: "Enable Notifications",
                    message: "To enable access, go to Settings > Privacy > Notifcation and turn on Microphone access for this app."
                )
                break
            default:
                print("Default error..")
            }
        }
    }
    
    func scheduleNotifcation(for reminderDate: Date, with body: String) {
        let content = UNMutableNotificationContent()
        content.title = "FullCast"
        content.subtitle = "You got a remainder"
        content.body = "Remainder for the recording \(body)"
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "full_cast_remainder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding request to the calender: \(error.localizedDescription)")
            }
        }
    }
    
    func closeCalendar() {
        DispatchQueue.main.async {
            withAnimation {
                self.showDatePicker.toggle()
            }
        }
    }
    
    private func getNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { isGranted, error in
            if let error = error {
                print("Error while getting notifcation permission \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                withAnimation {
                    self.showDatePicker = isGranted
                }
            }
        }
    }

    private func showAlertMessage(title: String, message: String) {
        let alert = AlertDetails(alertTitle: title, alertMessage: message)
        DispatchQueue.main.async {
            self.showNotificationAlert = true
            self.alertDetails = alert
        }
    }
    
}
