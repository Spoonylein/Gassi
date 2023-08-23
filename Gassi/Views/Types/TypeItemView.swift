//
//  TypeItemView.swift
//  Gassi
//
//  Created by Jan Löffel on 05.08.23.
//

import SwiftUI

struct TypeItemView: View {
    @ObservedObject var type: GassiType
    
    var showSubtypesCount: Bool = false
    
    var body: some View {
        HStack {
            Text(type.sign ?? localizedString("TypeSign"))
            Text(type.nameString)
            Spacer()
            if type.isPeeOrPoo {
                Image(systemName: "clock.badge.questionmark")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            if showSubtypesCount {
                Text("\(type.subtypes?.count ?? 0)")
                    .font(.footnote)
                    .foregroundColor((type.subtypes?.count ?? 0) > 0 ? .primary : .secondary)
            }
        }
    }
}

struct TypeItemView_Previews: PreviewProvider {
    static var previews: some View {
        TypeItemView(type: GassiType.poo, showSubtypesCount: true)
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
