//
//  AlertService.swift
//  FullCast
//
//  Created by Vishwa  R on 25/02/22.
//

import SwiftUI

final class AlertService {
    
    static let shared = AlertService()
    
    func showSettingsAlertBox(title: String, message: String) -> Alert {
        return Alert(
            title: Text("\(title)"),
            message: Text("\(message)"),
            primaryButton: .cancel(Text("Cancel")),
            secondaryButton: .default(Text("Settings"), action: Constants.openSettings)
        )
    }
}
