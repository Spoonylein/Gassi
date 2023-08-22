//
//  SexItemView.swift
//  Gassi
//
//  Created by Jan Löffel on 02.08.23.
//

import SwiftUI

struct SexItemView: View {
    @ObservedObject var sex: GassiSex
    
    var body: some View {
        HStack {
            Text(sex.name ?? "[no sex name]")
            Spacer()
            Text("\(sex.dogs?.count ?? 0)")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

struct SexItemView_Previews: PreviewProvider {
    static var previews: some View {
        let sex = GassiSex.new(context: CoreDataController.preview.container.viewContext, name: "Whippet")
        SexItemView(sex: sex)
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}

