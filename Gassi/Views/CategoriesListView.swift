//
//  GassiCategoriesListView.swift
//  Gassi
//
//  Created by Jan Löffel on 13.08.22.
//

import SwiftUI

struct CategoriesListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(fetchRequest: CDGassiCategory.fetchSortedRequest(), animation: .default) private var categories: FetchedResults<CDGassiCategory>
    
    var body: some View {
        List {
            
            Section {
                ForEach(categories, id: \.id) { item in
                    NavigationLink {
                        CategoryDetailsView(gassiCategory: item)
                    } label: {
                        CategoryRowView(gassiCategory: item)
                    }
                    .tag(item.id)
                    .deleteDisabled(item.isDefault)
                }
                .onDelete(perform: deleteItems)
            } header: {
                Label(LocalizedStringKey("CategoriesListSectionHeader"), systemImage: "folder.fill")
            } footer: {
                Label(LocalizedStringKey("CategoriesListSectionFooter"), systemImage: "info.circle")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            
            ToolbarItem(placement: .principal) {
                Button {
                    let _ = CDGassiCategory.new(viewContext: viewContext)
                } label: {
                    Label(LocalizedStringKey("AddCategory"), systemImage: "plus")
                }
            }
        }
        .navigationTitle(LocalizedStringKey("CategoriesListViewTitle"))
    }
    
    private func deleteItems(offsets: IndexSet) {
        for offset in offsets {
            let category = categories[offset]
            viewContext.delete(category)
        }
        CoreDataController.shared.save()
    }
}

struct GassiCategoriesListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoriesListView()
                .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
                .environmentObject(CoreDataController.preview.settings)
        }
    }
}
