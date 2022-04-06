//
//  CategoryView.swift
//  FullCast
//
//  Created by Vishwa  R on 08/02/22.
//

import SwiftUI

struct CategoryView: View {
    
    var categoryViewModel: CategoryProtocol
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Category.categoryName, ascending: true)]) var categories : FetchedResults<Category>
    
    init(viewModel: CategoryProtocol) {
        self.categoryViewModel = viewModel
        UINavigationBar.appearance().tintColor = .systemYellow
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    NavigationLink(destination: RecorderView(selectedCategory: category)) {
                        Text(category.wrappedCategoryName)
                    }
                }
                .onDelete(perform: deleteData)
            }
            .toolbar {
                Button(action: categoryViewModel.createNewCategory) {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(Color(UIColor.systemYellow))
                }
            }
            .navigationTitle("FullCast")
        }
        .navigationViewStyle(.stack)
    }
    
    private func deleteData(at offset: IndexSet) {
        offset.forEach { index in
            let category = categories[index]
            categoryViewModel.deleteCategoryOnCoreData(category)
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(viewModel: CategoryViewModel())
    }
}


