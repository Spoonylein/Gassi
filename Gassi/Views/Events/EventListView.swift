//
//  EventListView.swift
//  Gassi
//
//  Created by Jan Löffel on 05.08.23.
//

import SwiftUI

struct EventListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)], animation: .default) private var events: FetchedResults<GassiEvent>
    
    var body: some View {
        List {
            ForEach(events) { event in
                NavigationLink(value: event) {
                    EventItemView(event: event)
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
                    let event = GassiEvent.new(context: viewContext, dog: GassiDog.current, type: GassiType.pee)
                    navigationController.path.append(event)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for offset in offsets {
            let event = events[offset]
            viewContext.delete(event)
        }
        CoreDataController.shared.save()
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
            .environmentObject(NavigationController())
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
