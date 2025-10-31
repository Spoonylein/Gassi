//
//  GassiCategoriesListView.swift
//  Gassi
//
//  Created by Jan Löffel on 13.08.22.
//

import SwiftUI
import SpoonFW

struct CategoriesSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(fetchRequest: CDGassiCategory.fetchSortedRequest(), animation: .default) private var categories: FetchedResults<CDGassiCategory>

    @ObservedObject var gassiEvent: CDGassiEvent
    
    var body: some View {
        List {
            ForEach(categories, id: \.id) { item in
                HStack {
                    CategoryRowView(gassiCategory: item)
                    Spacer()
                    
                    Image(systemName: "checkmark")
                        .isHidden(item != gassiEvent.category)
                }
                .contentShape(Rectangle())
                .tag(item.id)
                .onTapGesture {
                    gassiEvent.category = item
                    dismiss()
                }
            }
        }
        .navigationTitle(LocalizedStringKey("CategoriesSelectionViewTitle"))
    }
}

struct CategoriesSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoriesSelectionView(gassiEvent: CDGassiEvent.new(viewContext: CoreDataController.preview.container.viewContext))
                .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
                .environmentObject(CoreDataController.preview.settings)
        }
    }
}
