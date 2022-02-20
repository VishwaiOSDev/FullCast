//
//  NotificationViewModel.swift
//  FullCast
//
//  Created by Vishwa  R on 18/02/22.
//

import Foundation
import UserNotifications

final class NotifcationViewModel: ObservableObject {
    
    @Published var showNotificationAlert = false
    @Published var alertDetails : AlertDetails?
    private var notificationModel = Notification()
    
    func requestAuthorization(for remainderDate: Date, with body: String, id: UUID) {
        let notificationDetails = notificationModel.getNotificationDetails(body, id, remainderDate)
        setupNotifcationManager(with: notificationDetails)
    }
    
    private func setupNotifcationManager(with details: Notification.Details) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.getNotificationPermission { success in
                    self.scheduleNotifcation(for: details)
                }
            case .authorized:
                self.scheduleNotifcation(for: details)
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
    
    private func scheduleNotifcation(for details: Notification.Details) {
        let content = UNMutableNotificationContent()
        content.title = "\(details.title)"
        content.subtitle = "\(details.subtitle)"
        content.body = "Remainder for the recording \(details.body)"
        let trigger = UNCalendarNotificationTrigger(dateMatching: details.reminderDate, repeats: false)
        let request = UNNotificationRequest(identifier: "full_cast_remainder \(details.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding request to the calender: \(error.localizedDescription)")
            }
        }
    }
    
    private func getNotificationPermission(completionHandler: @escaping (_ success: Bool) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Error while getting notifcation permission \(error.localizedDescription)")
            }
            completionHandler(success)
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
