//
//  BreedListView.swift
//  Gassi
//
//  Created by Jan Löffel on 02.08.23.
//

import SwiftUI

struct BreedListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var breeds: FetchedResults<GassiBreed>

    var body: some View {
        List {
            ForEach(breeds) { breed in
                BreedItemView(breed: breed)
            }
            .onDelete(perform: deleteItems)
        }
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
        BreedListView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
