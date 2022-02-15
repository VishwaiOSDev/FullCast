//
//  Category.swift
//  FullCast
//
//  Created by Vishwa  R on 08/02/22.
//

import Foundation

struct CategoryModel {
    func saveFolderNameInCoreData(folderName : String) {
        let newCategory = Category(context: CoreDataController.shared.viewContext)
        newCategory.id = UUID()
        newCategory.categoryName = folderName
        CoreDataController.shared.save()
    }
    
}
