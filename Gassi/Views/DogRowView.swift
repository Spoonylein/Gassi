//
//  DogRowView.swift
//  Gassi
//
//  Created by Jan Löffel on 21.08.22.
//

import SwiftUI

struct DogRowView: View {
    @ObservedObject var dog: CDGassiDog
    
    var body: some View {
        Label {
            Text(dog.name)
        } icon: {
         Image(systemName: "pawprint.fill")
        }
    }
}

struct DogRowView_Previews: PreviewProvider {
    static var previews: some View {
        let dog = CDGassiDog.new(viewContext: CoreDataController.preview.container.viewContext)
        DogRowView(dog: dog)
    }
}
