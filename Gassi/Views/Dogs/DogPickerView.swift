//
//  DogPickerView.swift
//  Gassi
//
//  Created by Jan Löffel on 06.08.23.
//

import SwiftUI

struct DogPickerView: View {
    @ObservedObject var event: GassiEvent
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "birthday", ascending: false)], animation: .default) private var dogs: FetchedResults<GassiDog>

    var body: some View {
        Picker(selection: $event.dog) {
            ForEach(dogs) { dog in
                Text(dog.nameString)
                    .tag(dog as GassiDog?)
            }
        } label: {
            Label {
                Text(LocalizedStringKey("Dog"))
            } icon: {
                Image(systemName: "pawprint.fill")
            }
        }
    }
}

struct DogPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DogPickerView(event: GassiEvent.new(context: CoreDataController.preview.container.viewContext, dog: GassiDog.current, type: GassiType.pee))
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
