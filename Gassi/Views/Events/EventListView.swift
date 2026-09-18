//
//  EventListView.swift
//  Gassi
//
//  Created by Jan Löffel on 05.08.23.
//

import CoreData
import SwiftUI

private enum EventDateSortOrder: String, CaseIterable, Identifiable {
    case descending
    case ascending

    var id: Self { self }
}

struct EventListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)], animation: .default) private var events: FetchedResults<GassiEvent>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "birthday", ascending: false)], animation: .default) private var dogs: FetchedResults<GassiDog>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var types: FetchedResults<GassiType>

    @State private var selectedDog: GassiDog?
    @State private var selectedType: GassiType?
    @State private var dateSortOrder = EventDateSortOrder.descending

    private var displayedEvents: [GassiEvent] {
        events
            .filter { event in
                (selectedDog == nil || event.dog == selectedDog)
                    && (selectedType == nil || event.type == selectedType)
            }
            .sorted { firstEvent, secondEvent in
                switch (firstEvent.timestamp, secondEvent.timestamp) {
                case let (firstDate?, secondDate?):
                    return dateSortOrder == .ascending
                        ? firstDate < secondDate
                        : firstDate > secondDate
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                case (nil, nil):
                    return false
                }
            }
    }

    var body: some View {
        List {
            ForEach(displayedEvents) { event in
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
                Menu {
                    Picker("SortByDate", selection: $dateSortOrder) {
                        Text("DateDescending")
                            .tag(EventDateSortOrder.descending)
                        Text("DateAscending")
                            .tag(EventDateSortOrder.ascending)
                    }
                } label: {
                    Image(systemName: dateSortOrder == .ascending
                        ? "arrow.up.circle"
                        : "arrow.down.circle")
                }
                .accessibilityLabel("SortEvents")
            }
            ToolbarItem {
                Menu {
                    Picker("Dog", selection: $selectedDog) {
                        Text("AllDogs")
                            .tag(nil as GassiDog?)
                        ForEach(dogs) { dog in
                            Text(dog.nameString)
                                .tag(dog as GassiDog?)
                        }
                    }

                    Picker("Type", selection: $selectedType) {
                        Text("AllTypes")
                            .tag(nil as GassiType?)
                        ForEach(types) { type in
                            Text((type.sign ?? "TypeSign") + " " + type.nameString)
                                .tag(type as GassiType?)
                        }
                    }
                } label: {
                    Image(systemName: selectedDog == nil && selectedType == nil
                        ? "line.3.horizontal.decrease.circle"
                        : "line.3.horizontal.decrease.circle.fill")
                }
                .accessibilityLabel("FilterEvents")
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
            viewContext.delete(displayedEvents[offset])
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
