//
//  BreedItemView.swift
//  Gassi
//
//  Created by Jan Löffel on 02.08.23.
//

import SwiftUI

struct BreedItemView: View {
    @ObservedObject var breed: GassiBreed
    
    var body: some View {
        HStack {
            Text(breed.nameString)
            Spacer()
            Text("\(breed.dogs?.count ?? 0)")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

struct BreedItemView_Previews: PreviewProvider {
    static var previews: some View {
        let breed = GassiBreed.new(context: CoreDataController.preview.container.viewContext, name: "Whippet")
        BreedItemView(breed: breed)
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}

