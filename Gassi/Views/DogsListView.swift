//
//  DogsListView.swift
//  Gassi
//
//  Created by Jan Löffel on 21.08.22.
//

import SwiftUI

struct DogsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: CDGassiSettings

    @FetchRequest(fetchRequest: CDGassiDog.fetchSortedRequest(), animation: .default) private var dogs: FetchedResults<CDGassiDog>
    @FetchRequest(fetchRequest: CDGassiEvent.sortedFetchRequest(), animation: .default) private var events: FetchedResults<CDGassiEvent>

    var body: some View {
        List {
            ForEach(dogs, id: \.id) { item in
                NavigationLink {
                    DogDetailsView(dog: item)
                } label: {
                    DogRowView(dog: item)
                }
                .tag(item.id)
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .principal) {
                Button {
                    let dog = CDGassiDog.new(viewContext: viewContext)
                    if settings.currentDog == nil { settings.currentDog = dog }
                } label: {
                    Image(systemName: "plus")
                }

            }
        }
        .navigationTitle(LocalizedStringKey("DogsListViewTitle"))
    }
    
    private func deleteItems(offsets: IndexSet) {
        for offset in offsets {
            let dog = dogs[offset]

            for event in events.filter({ event in
                return event.dog == dog
            }) {
                event.dog = nil
            }

            viewContext.delete(dog)
        }
        CoreDataController.shared.save()
    }
}

struct DogsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DogsListView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
            .environmentObject(CoreDataController.preview.settings)
        }
    }
}
