//
//  EventsView.swift
//  Gassi
//
//  Created by Jan Löffel on 02.08.23.
//

import SwiftUI

struct EventsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    var body: some View {

        NavigationStack(path: $navigationController.path) {
            EventListView()
                .navigationDestination(for: [GassiEvent].self) { events in
                    EventListView()
                }
                .navigationDestination(for: GassiEvent.self) { event in
                    EventView(event: event)
                }
                .navigationTitle(LocalizedStringKey("Events"))
        }

    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
            .environmentObject(NavigationController())
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
