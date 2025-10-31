//
//  GassiEventsListView.swift
//  Gassi
//
//  Created by Jan Löffel on 30.12.21.
//

import SwiftUI
import SpoonFW
import MapKit

struct EventsItemsView: View {
    @FetchRequest(fetchRequest: CDGassiCategory.fetchSortedRequest(), animation: .default) private var categories: FetchedResults<CDGassiCategory>

    @State private var category: CDGassiCategory? = nil
    @State private var isShownAsMap: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                VStack(alignment: .trailing) {
                    Toggle(isOn: $isShownAsMap) {
                        Label(LocalizedStringKey("EventsListViewIsShownAsMap"), systemImage: "map")
                    }

                    if !isShownAsMap {
                        HStack {
                            Label(LocalizedStringKey("EventsListViewCategoryFilter"), systemImage: "folder")
                            Spacer()
                            Picker(LocalizedStringKey("EventsListViewCategoryFilter"), selection: $category) {
                                Text(LocalizedStringKey("EventsListViewAllCategories"))
                                    .tag(nil as CDGassiCategory?)
                                ForEach(categories, id: \.id) { category in
                                    Text("\(category.sign) \(category.name)")
                                        .tag(category as CDGassiCategory?)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    } else {
                        EmptyView()
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)

                if isShownAsMap {
                    EventsMapView(category: category)
                } else {
                    EventsListView(category: category)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    DogMenuView()
                }
            }
            .navigationTitle(LocalizedStringKey("EventsListViewTitle"))
        }
        .navigationViewStyle(.stack)
    }
}

struct GassiEventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsItemsView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
            .environmentObject(CoreDataController.preview.settings)
    }
}

struct EventsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: CDGassiSettings
    
    @FetchRequest(fetchRequest: CDGassiEvent.sortedFetchRequest(ascending: false), animation: .default) private var events: FetchedResults<CDGassiEvent>

    let category: CDGassiCategory?
    
    var body: some View {
        List {
            ForEach(CDGassiEvent.eventDays(events: events.filter( { item in
                return (item.dog == settings.currentDog || settings.currentDog == nil || item.dog == nil)
            })), id: \.self) { eventDay in
                Section(eventDay.formatted(date: .complete, time: .omitted)) {
                    ForEach(events, id: \.id) { item in
                        if (item.category == category || category == nil)
                            && Calendar.current.isDate(item.timestamp, inSameDayAs: eventDay) {
                            NavigationLink {
                                EventDetailsView(gassiEvent: item)
                            } label: {
                                EventRowView(gassiEvent: item)
                            }
                            .tag(item.id)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func deleteItems(offsets: IndexSet) {
        for offset in offsets {
            let event = events[offset]
            viewContext.delete(event)
        }
    }
}

struct EventsMapView: View {
    struct GassiAnnotation: Identifiable {
        let coordinate: CLLocationCoordinate2D
        let title: String?
        let id: UUID = UUID()
        
        init(coordinate: CLLocationCoordinate2D, title: String? = nil) {
            self.coordinate = coordinate
            self.title = title
        }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: CDGassiSettings

    @FetchRequest(fetchRequest: CDGassiEvent.sortedFetchRequest(ascending: false), animation: .default) private var events: FetchedResults<CDGassiEvent>
    let category: CDGassiCategory?
    
    @State private var mapRect: MKMapRect = MKMapRect()
    @State private var annotations: [GassiAnnotation] = []

    var body: some View {
        Map(mapRect: $mapRect, annotationItems: annotations) { annotation in
            MapMarker(coordinate: annotation.coordinate)
        }.onAppear {
            let categoryEventsWithLocation = events.filter( { item in
                return (item.dog == settings.currentDog || settings.currentDog == nil || item.dog == nil) &&
                (item.category == category || category == nil) &&
                (item.longitude != 0 && item.latitude != 0)
            })
            categoryEventsWithLocation.forEach({ event in
                annotations.append(GassiAnnotation(coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)))
            })
            let points = annotations.map(\.coordinate).map(MKMapPoint.init)
            mapRect = points.reduce(MKMapRect.null) { rect, point in
                let newRect = MKMapRect(origin: point, size: MKMapSize())
                return rect.union(newRect)
            }
        }
    }
}
