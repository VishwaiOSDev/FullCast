//
//  CategoryViewModel.swift
//  FullCast
//
//  Created by Vishwa  R on 08/02/22.
//

import UIKit

struct Folder : Identifiable {
    var id = UUID()
    var folderName : String
}

final class CategoryViewModel: ObservableObject {
    
    init() {
        UITextField.appearance().tintColor = .systemYellow
    }
    
    @Published var folders : [Folder] = []
    private var alert : UIAlertController?
    private var categoryModel = CategoryModel()
}

extension CategoryViewModel {
    func showPrompt() {
        var textField = UITextField()
        alert = UIAlertController(title: "New Folder", message: "Enter a name for this folder", preferredStyle: .alert)
        alert?.addTextField { folderName in
            folderName.placeholder = "Name"
            textField = folderName
            folderName.addTarget(self, action: #selector(self.alertTextFieldDidChange), for: .editingChanged)
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let newFolder = Folder(folderName: textField.text!)
            self.folders.append(newFolder)
            self.categoryModel.saveFolderNameInCoreData(folderName: textField.text!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        cancelAction.setValue(UIColor.systemYellow, forKey: "titleTextColor")
        saveAction.isEnabled = false
        alert?.addAction(saveAction)
        alert?.addAction(cancelAction)
        presentAlert(of : alert!)
    }
    
    @objc private func alertTextFieldDidChange(_ sender: UITextField) {
        alert?.actions[0].isEnabled = sender.text!.count > 0
    }
    
    private func presentAlert(of alert : UIAlertController) {
        if #available(iOS 14.0, *) {
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            let scenes = UIApplication.shared.connectedScenes
            let windowScenes = scenes.first as? UIWindowScene
            let window = windowScenes?.windows.first
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

