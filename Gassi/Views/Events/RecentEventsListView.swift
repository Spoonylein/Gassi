//
//  RecentEventsView.swift
//  Gassi
//
//  Created by Jan Löffel on 17.08.22.
//

import SwiftUI
import CoreData

struct RecentEventsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "predict == TRUE"), animation: .default) private var predictableTypes: FetchedResults<GassiType>

    var body: some View {
        List {
            Section {
                ForEach(predictableTypes) { type in
                    RecentEventRowView(type: type, dog: GassiDog.current)
                        .id(recentEventRowID(type: type))
                }
            } header: {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("lastEvent")
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Text("nextEvent")
                        Image(systemName: "timer")
                    }
                }
            }
        }
        .listStyle(.plain)
        .task(id: predictionRefreshTaskID) {
            navigationController.beginPredictionRefresh(expectedResults: predictableTypes.count)
        }
        .refreshable {
            navigationController.recalculateNextPrediction()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .NSManagedObjectContextObjectsDidChange,
                object: viewContext
            )
        ) { notification in
            guard containsEventChanges(notification) else { return }
            navigationController.recalculateNextPrediction()
        }
    }

    private var predictionRefreshTaskID: String {
        "\(GassiDog.current.id?.uuidString ?? GassiDog.current.objectID.uriRepresentation().absoluteString)-\(predictableTypes.count)-\(navigationController.nextPredictionRefreshID.uuidString)"
    }

    private func recentEventRowID(type: GassiType) -> String {
        let dogID = GassiDog.current.id?.uuidString ?? GassiDog.current.objectID.uriRepresentation().absoluteString
        let typeID = type.id?.uuidString ?? type.objectID.uriRepresentation().absoluteString
        return "\(dogID)-\(typeID)"
    }

    private func containsEventChanges(_ notification: Notification) -> Bool {
        let eventChangeKeys = [NSInsertedObjectsKey, NSUpdatedObjectsKey, NSDeletedObjectsKey]

        return eventChangeKeys.contains { key in
            guard let objects = notification.userInfo?[key] as? Set<NSManagedObject> else {
                return false
            }

            return objects.contains { $0 is GassiEvent }
        }
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
