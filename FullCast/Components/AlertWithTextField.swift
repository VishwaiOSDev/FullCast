//
//  AlertWithTextField.swift
//  FullCast
//
//  Created by Vishwa  R on 23/02/22.
//

import SwiftUI

struct AlertWithTextField: ViewModifier {
    
    @State private var alertController: UIAlertController?
    @Binding var isPresented: Bool
    var text: String
    let action: (String?) -> Void
 
    func body(content: Content) -> some View {
        content.onChange(of: isPresented) { isPresented in
            if isPresented, alertController == nil {
                let alertController = makeAlertController()
                self.alertController = alertController
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                scene.windows.first?.rootViewController?.present(alertController, animated: true)
            } else if !isPresented, let alertController = alertController {
                alertController.dismiss(animated: true)
                self.alertController = nil
            }
        }
    }
    
    private func makeAlertController() -> UIAlertController {
        let controller = UIAlertController(title: "New Folder", message: "Enter a name for this folder", preferredStyle: .alert)
        controller.addTextField {
            $0.placeholder = "Name"
            $0.text = self.text
        }
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.action(nil)
            shutdown()
        }))
        controller.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            self.action(controller.textFields?.first?.text)
            shutdown()
        }))
        return controller
    }
    
    private func shutdown() {
       isPresented = false
       alertController = nil
    }
    
}
