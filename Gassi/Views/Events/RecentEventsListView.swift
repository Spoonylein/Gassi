//
//  RecentEventsView.swift
//  Gassi
//
//  Created by Jan Löffel on 17.08.22.
//

import SwiftUI

struct RecentEventsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "predict == TRUE"), animation: .default) private var predictableTypes: FetchedResults<GassiType>

    var body: some View {
        List {
            Section {
                ForEach(predictableTypes) { type in
                    RecentEventRowView(type: type)
                }
            } header: {
                HStack {
                    Label("lastEvent", systemImage: "clock.arrow.circlepath")
                    Spacer()
                    Label("nextEvent", systemImage: "timer")
                }
            }
        }
        .listStyle(.plain)
    }
    
}

struct RecentEventsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecentEventsListView()
                .environmentObject(NavigationController())
                .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
        }
    }
}
