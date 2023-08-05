//
//  TypeItemView.swift
//  Gassi
//
//  Created by Jan Löffel on 05.08.23.
//

import SwiftUI

struct TypeItemView: View {
    @ObservedObject var type: GassiType
    
    var body: some View {
        HStack {
            Text(type.sign ?? localizedString("TypeSign"))
            Text(type.nameString)
                .foregroundColor((type.events?.count ?? 0) > 0 ? .primary : .secondary)
            Spacer()
            Text("\(type.events?.count ?? 0)")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

struct TypeItemView_Previews: PreviewProvider {
    static var previews: some View {
        TypeItemView(type: GassiType.pee)
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
