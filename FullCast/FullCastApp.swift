//
//  FullCastApp.swift
//  FullCast
//
//  Created by Vishwa  R on 03/02/22.
//

import SwiftUI

@main
struct FullCastApp: App {
    
    private let context = CoreDataController.shared.viewContext
    
    var body: some Scene {
        WindowGroup {
            CategoryView()
                .environment(\.managedObjectContext, context)
        }
    }
}
