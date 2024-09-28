//
//  TypePickerView.swift
//  Gassi
//
//  Created by Jan Löffel on 06.08.23.
//

import SwiftUI

struct TypePickerView: View {
    @ObservedObject var event: GassiEvent
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var types: FetchedResults<GassiType>

    var body: some View {
        Picker(selection: $event.type) {
            Text("NoType")
                .tag(nil as GassiType?)
            ForEach(types) { type in
                // Double Check !
                Text((type.sign ?? "TypeSign") + " " + type.nameString)
                    .tag(type as GassiType?)
            }
        } label: {
            Label {
                Text("Type")
            } icon: {
                Image(systemName: "list.bullet")
            }
        }
    }
}

struct TypePickerView_Previews: PreviewProvider {
    static var previews: some View {
        TypePickerView(event: GassiEvent.new(context: CoreDataController.preview.container.viewContext, dog: GassiDog.current, type: GassiType.pee))
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
