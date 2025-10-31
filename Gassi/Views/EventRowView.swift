//
//  EventRowView.swift
//  Gassi
//
//  Created by Jan Löffel on 13.08.22.
//

import SwiftUI
import SpoonFW

struct EventRowView: View {
    @EnvironmentObject private var geoController: GeoController
    
    @FetchRequest(fetchRequest: CDGassiDog.fetchSortedRequest(), animation: .default) private var dogs: FetchedResults<CDGassiDog>

    @ObservedObject var gassiEvent: CDGassiEvent
    
    var body: some View {

        HStack {
            
            VStack {
                if let sign = gassiEvent.category?.sign {
                    Text(sign).font(.title)
                }
                
                Text(gassiEvent.dog?.name ?? ( dogs.count == 0 ? NSLocalizedString("YourDog", comment: "") : NSLocalizedString("AllDogs", comment: "")))
                    .font(.footnote)
            }

            if gassiEvent.longitude != 0.0 && gassiEvent.latitude != 0.0 {
                Image(systemName: "location.fill").font(.footnote)
                    .foregroundColor((geoController.locationStatus == .denied || geoController.locationStatus == .restricted || geoController.locationStatus == .notDetermined) ? .secondary : .primary)
            }

            Spacer()
            
            Text(gassiEvent.timestamp.weekday() + ",")
            Text(gassiEvent.timestamp.formatted(date: .numeric, time: .shortened))
        }
    }
}

struct EventRowView_Previews: PreviewProvider {
    static var previews: some View {
        let gassiEvent = CDGassiEvent.new(viewContext: CoreDataController.preview.container.viewContext, category: CoreDataController.preview.settings.favoriteCategory2!)
        EventRowView(gassiEvent: gassiEvent)
            .environmentObject(CoreDataController.preview.settings)
    }
}
