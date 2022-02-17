//
//  CategoryView.swift
//  FullCast
//
//  Created by Vishwa  R on 08/02/22.
//

import SwiftUI

struct CategoryView: View {
    
    @StateObject private var categoryViewModel = CategoryViewModel()
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Category.categoryName, ascending: true)]) var categories : FetchedResults<Category>
    
    init() {
        UINavigationBar.appearance().tintColor = .systemYellow
    }
    
    var body: some View {
        NavigationView {
            categoryList
                .toolbar {
                    Button(action: newFolderButtonPressed) {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(Color(UIColor.systemYellow))
                    }
                }
                .navigationTitle("FullCast")
        }
        .navigationViewStyle(.stack)
    }
    
    private var categoryList : some View {
        List {
            ForEach(categories) { category in
                NavigationLink(destination: RecorderView(selectedCategory: category)) {
                    Text(category.wrappedCategoryName)
                }
            }
            .onDelete(perform: deleteCategory)
        }
    }
    
    private func newFolderButtonPressed() {
        categoryViewModel.showPrompt()
    }
    
    private func deleteCategory(at offset: IndexSet) {
        offset.forEach { index in
            let category = categories[index]
            CoreDataController.shared.viewContext.delete(category)
        }
        CoreDataController.shared.save()
    }
    
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView()
    }
}
