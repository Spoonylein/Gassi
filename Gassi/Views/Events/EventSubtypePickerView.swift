//
//  SubtypePickerView.swift
//  Gassi
//
//  Created by Jan Löffel on 06.08.23.
//

import SwiftUI

struct EventSubtypePickerView: View {
    @ObservedObject var event: GassiEvent
    
    var type: GassiType? = nil
    
    @FetchRequest private var subtypes: FetchedResults<GassiSubtype>
    
    init(event: GassiEvent, type: GassiType? = nil) {
        var subtypesPredicate = NSPredicate(value: true)
        self.event = event
        self.type = type
        
        if let _type = type {
            subtypesPredicate = NSPredicate(format: "type = %@", _type)
        }
        
        _subtypes = FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: subtypesPredicate, animation: .default)
    }
    
    var body: some View {
        Picker(selection: $event.subtype) {
            Text("NoSubtype")
                .tag(nil as GassiSubtype?)
            ForEach(subtypes) { subtype in
                Text((subtype.sign ?? "TypeSign") + " " + subtype.nameString)
                    .tag(subtype as GassiSubtype?)
            }
        } label: {
            Label {
                Text("Subtype")
            } icon: {
                Image(systemName: "list.bullet.indent")
            }
        }
    }
}

struct SubtypePickerView_Previews: PreviewProvider {
    static var previews: some View {
        EventSubtypePickerView(event: GassiEvent.new(context: CoreDataController.preview.container.viewContext, dog: GassiDog.current, type: GassiType.pee))
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
