//
//  CategoryView.swift
//  FullCast
//
//  Created by Vishwa  R on 08/02/22.
//

import SwiftUI

struct CategoryView: View {
    
    @StateObject private var categoryViewModel = CategoryViewModel()
    @FetchRequest(entity: Category.entity(), sortDescriptors: []) var categories : FetchedResults<Category>
    
    var body: some View {
        NavigationView {
            List(categories) { category in
                NavigationLink(destination: RecorderView(selectedCategory: category)) {
                    Text(category.wrappedCategoryName)
                }
            }
            .toolbar {
                Button(action: newFolderButtonPressed) {
                    Image(systemName: "folder.badge.plus")
                }
            }
            .navigationTitle("FullCast")
        }
        .navigationViewStyle(.stack)
    }
    
    private func newFolderButtonPressed() {
        categoryViewModel.showPrompt()
    }
    
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView()
    }
}
