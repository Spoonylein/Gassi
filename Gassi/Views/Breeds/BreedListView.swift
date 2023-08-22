//
//  BreedListView.swift
//  Gassi
//
//  Created by Jan Löffel on 02.08.23.
//

import SwiftUI

struct BreedListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var breeds: FetchedResults<GassiBreed>

    var body: some View {
        List {
            ForEach(breeds) { breed in
                NavigationLink(value: breed) {
                    BreedItemView(breed: breed)
                }
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            ToolbarItem {
                EditButton()
            }
            ToolbarItem {
                Button {
                    let breed = GassiBreed.new(context: viewContext)
                    navigationController.path.append(breed)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle(LocalizedStringKey("Breeds"))
        .toolbar(SwiftUI.Visibility.hidden, for: SwiftUI.ToolbarPlacement.tabBar)
    }
    
    private func deleteItems(offsets: IndexSet) {
        for offset in offsets {
            let breed = breeds[offset]
            viewContext.delete(breed)
        }
        CoreDataController.shared.save()
    }

}

struct BreedListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BreedListView()
                .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
        }
    }
}
