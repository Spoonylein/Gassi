//
//  EventItemView.swift
//  Gassi
//
//  Created by Jan Löffel on 05.08.23.
//

import SwiftUI

struct EventItemView: View {
    
    @ObservedObject var event: GassiEvent
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "birthday", ascending: false)], animation: .default) private var dogs: FetchedResults<GassiDog>

    var body: some View {
            HStack(alignment: .center) {
                if let subtype = event.subtype {
                    Text(subtype.sign ?? localizedString("TypeSign"))
                } else {
                    Text(event.type?.sign ?? localizedString("TypeSign"))
                }
                VStack(alignment: .leading) {
                    Text(event.type?.nameString ?? localizedString("NoType"))
                    if let subtype = event.subtype {
                        Text(" - " + subtype.nameString)
                    }
                    if dogs.count > 1 {
                        Text(event.dog?.nameString ?? localizedString("NoDog"))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Text(event.timestamp?.formatted() ?? localizedString("NoTimestamp"))
            }
    }
}

struct EventItemView_Previews: PreviewProvider {
    static var previews: some View {
        let event = GassiEvent.new(context: CoreDataController.preview.container.viewContext, dog: GassiDog.current, type: GassiType.pee)
        EventItemView(event: event)
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
