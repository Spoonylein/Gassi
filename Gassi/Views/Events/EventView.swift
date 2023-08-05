//
//  EventView.swift
//  Gassi
//
//  Created by Jan Löffel on 05.08.23.
//

import SwiftUI

struct EventView: View {
    @ObservedObject var event: GassiEvent
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: GassiEvent.new(context: CoreDataController.preview.container.viewContext, dog: GassiDog.current, type: GassiType.pee))
    }
}
