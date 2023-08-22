//
//  SubtypeItemView.swift
//  Gassi
//
//  Created by Jan Löffel on 05.08.23.
//

import SwiftUI

struct SubtypeItemView: View {
    @ObservedObject var subtype: GassiSubtype
    
    var body: some View {
        HStack {
            Text(subtype.sign ?? localizedString("SubtypeSign"))
            Text(subtype.nameString)
        }
    }
}

struct SubtypeItemView_Previews: PreviewProvider {
    static var previews: some View {
        SubtypeItemView(subtype: GassiSubtype.newHardPoo(context: CoreDataController.preview.container.viewContext))
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
