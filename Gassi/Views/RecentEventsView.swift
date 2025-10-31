//
//  RecentEventsView.swift
//  Gassi
//
//  Created by Jan Löffel on 17.08.22.
//

import SwiftUI

struct RecentEventsView: View {
    @EnvironmentObject var settings: CDGassiSettings
    
//    @FetchRequest(fetchRequest: CDGassiEvent.sortedFetchRequest(ascending: false), animation: .default) private var events: FetchedResults<CDGassiEvent>
    @FetchRequest(fetchRequest: CDGassiCategory.fetchSortedRequest(), animation: .default) private var categories: FetchedResults<CDGassiCategory>

    var body: some View {
        List {
            Section {
                ForEach(categories.filter( { item in
                    return item.isDefault
                })) { category in
                    RecentEventRowView(category: category)
                }
            } header: {
                HStack {
                    Label(LocalizedStringKey("lastGassi"), systemImage: "clock.arrow.circlepath")
                    Spacer()
                    Label(LocalizedStringKey("nextGassi"), systemImage: "timer")
                }
            }
        }
        .listStyle(.plain)
    }
    
}

struct RecentEventsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentEventsView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
            .environmentObject(CoreDataController.preview.settings)
    }
}
