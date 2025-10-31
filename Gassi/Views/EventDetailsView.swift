//
//  EventDetailView.swift
//  Gassi
//
//  Created by Jan Löffel on 13.08.22.
//

import SwiftUI
import CoreLocation
import MapKit
import SpoonFW

struct EventDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(fetchRequest: CDGassiDog.fetchSortedRequest(), animation: .default) private var dogs: FetchedResults<CDGassiDog>

    @ObservedObject var gassiEvent: CDGassiEvent
    
    @EnvironmentObject private var geoController: GeoController
    @State private var locationName: String? = nil
    
    @State private var timestamp: Date = .now
    @State private var category: CDGassiCategory? = nil
    @State private var dog: CDGassiDog? = nil

    var body: some View {

        Form {
            List {
                
                Section {
                    Label {
                        DatePicker(LocalizedStringKey("Timestamp"), selection: $timestamp, in: ...Date.now)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    
                    NavigationLink {
//                        LocationView(latitude: $gassiEvent.latitude, longitude: $gassiEvent.longitude, locationName: Binding<String>.convertOptionalString($locationName))
                        PlacemarkView(latitude: $gassiEvent.latitude, longitude: $gassiEvent.longitude, locationName: Binding<String>.convertOptionalString($locationName), geoController: geoController)
                    } label: {
                        Label {
                            Text(LocalizedStringKey("EventDetailsViewLocation"))
                            Spacer()
                            Text(locationName ?? NSLocalizedString("EventDetailsViewNoLocationName", comment: ""))
                        } icon: {
                            Image(systemName: "mappin.and.ellipse")
                        }
                    }
                    .disabled(geoController.locationStatus == .denied || geoController.locationStatus == .restricted || geoController.locationStatus == .notDetermined)
                    
                } header: {
                    Label(LocalizedStringKey("EventDetailsDateSectionHeader"), systemImage: "clock.fill")
                } footer: {
                    if (geoController.locationStatus == .denied || geoController.locationStatus == .restricted || geoController.locationStatus == .notDetermined) {
                        Label(LocalizedStringKey("EventDetailsDateSectionFooterNoLocation"), systemImage: "info.circle")
                    } else {
                        Label(LocalizedStringKey("EventDetailsDateSectionFooter"), systemImage: "info.circle")
                    }
                }

                Section {
                    NavigationLink {
                        CategoriesSelectionView(gassiEvent: gassiEvent)
                    } label: {
                        Label {
                            Text(LocalizedStringKey("EventDetailsCategory"))
                            Spacer()

                            if let category = self.category {
                                CategoryRowView(gassiCategory: category)
                                    .foregroundColor(.accentColor)
                            }
                        } icon: {
                            Image(systemName: "folder")
                        }
                    }
                    
                    NavigationLink {
                        EventDogSelectionView(gassiEvent: gassiEvent)
                    } label: {
                        Label {
                            Text(LocalizedStringKey("EventDetailsDog"))
                            Spacer()

                            Text(dog?.name ?? ( dogs.count == 0 ? NSLocalizedString("YourDog", comment: "") : NSLocalizedString("AllDogs", comment: "")))
                                .foregroundColor(.accentColor)
                        } icon: {
                            Image(systemName: "pawprint")
                        }
                    }

                } header: {
                    Label(LocalizedStringKey("EventDetailsCategorySectionHeader"), systemImage: "folder.fill")
                } footer: {
                    Label(LocalizedStringKey("EventDetailsCategorySectionFooter"), systemImage: "info.circle")
                }

            }
        }
        .onAppear {
            timestamp = gassiEvent.timestamp
            category = gassiEvent.category
            dog = gassiEvent.dog
            
            geoController.lookUpLocation(location: CLLocationCoordinate2D(latitude: gassiEvent.latitude, longitude: gassiEvent.longitude), completionHandler: { placemark in
                if let p = placemark, gassiEvent.latitude != 0 && gassiEvent.longitude != 0 {
                    locationName = p.name
                }
            })
        }
        .onDisappear {
            gassiEvent.timestamp = timestamp
            gassiEvent.category = category
            gassiEvent.dog = dog
        }
        .toolbar {
            ToolbarItem {
                Button {
                    viewContext.delete(gassiEvent)
                    dismiss()
                } label: {
                    Label(LocalizedStringKey("Delete"), systemImage: "trash")
                        .foregroundColor(Color.red)
                }

            }
        }
        .navigationTitle(LocalizedStringKey("EventDetailsViewTitle"))

    }
}

struct LocationView: View {
    struct GassiAnnotation: Identifiable {
        let coordinate: CLLocationCoordinate2D
        let title: String?
        let id: UUID = UUID()
        
        init(coordinate: CLLocationCoordinate2D, title: String? = nil) {
            self.coordinate = coordinate
            self.title = title
        }
    }
    
    @Binding var latitude: Double
    @Binding var longitude: Double
    @Binding var locationName: String

    @EnvironmentObject private var geoController: GeoController
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    @State private var annotations: [GassiAnnotation] = []
    
    var body: some View {
        List {
            Section {
                Label {
                    Text(LocalizedStringKey("LocationViewLocationName"))
                    Spacer()
                    Text(locationName)
                } icon: {
                    Image(systemName: "mappin.square")
                }

                GeometryReader(content: { proxy in
                    Map(coordinateRegion: $mapRegion, annotationItems: annotations, annotationContent: { annotation in
                        MapMarker(coordinate: annotation.coordinate)
                    })
                    .onTapGesture { location in
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        let newCoordinates = GeoController.convertTap(at: location, for: proxy.size, in: mapRegion)
                        longitude = newCoordinates.longitude
                        latitude = newCoordinates.latitude
                        withAnimation {
                            mapRegion.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        }
                        annotations = [GassiAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), title: locationName)]
                        geoController.lookUpLocation(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), completionHandler: { placemark in
                            self.locationName = placemark?.name ?? ""
                        })
                        generator.impactOccurred()
                    }
                    .onLongPressGesture {
                        let generator = UINotificationFeedbackGenerator()
                        longitude = geoController.location?.coordinate.longitude ?? 0
                        latitude = geoController.location?.coordinate.latitude ?? 0
                        withAnimation {
                            mapRegion.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        }
                        annotations = [GassiAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), title: locationName)]
                        geoController.lookUpLocation(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), completionHandler: { placemark in
                            self.locationName = placemark?.name ?? ""
                        })
                        generator.notificationOccurred(.success)
                    }
                })
                .frame(minHeight: 300)
                .padding(.vertical)
            } footer: {
                Label(LocalizedStringKey("LocationViewMapFooter"), systemImage: "info.circle")
            }
            
        }
        .onAppear {
            mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters: 500, longitudinalMeters: 500)
            annotations = [GassiAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), title: locationName)]
        }
        .navigationTitle(LocalizedStringKey("LocationViewTitle"))
    }
}

struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventDetailsView(gassiEvent: CDGassiEvent.new(viewContext: CoreDataController.preview.container.viewContext, category: CoreDataController.preview.settings.favoriteCategory1!))
                .environmentObject(CoreDataController.preview.settings)
                .environmentObject(GeoController())
        }
        
        NavigationView {
            LocationView(latitude: .constant(0), longitude: .constant(0), locationName: .constant("zuhause"))
                .environmentObject(GeoController())
        }
    }
}
