//
//  DogItemView.swift
//  Gassi
//
//  Created by Jan Löffel on 31.07.23.
//

import SwiftUI

struct DogItemView: View {
    
    @ObservedObject var dog: GassiDog
    
    var body: some View {
        HStack(alignment: .center) {
            Text(dog.nameString)
                .padding(.trailing, 25)
            Spacer()
            
            VStack(alignment: .trailing) {
                if dog.breed != nil {
                    Text(dog.breedNameString)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    if dog.sex != nil {
                        HStack(spacing: 0) {
//                            Text(LocalizedStringKey("DogItemSex"))
                            Text(dog.sexNameString)
                        }
                    }
                    if dog.birthday != nil {
                        HStack(spacing: 0) {
                            Text(LocalizedStringKey("DogItemAge"))
                            Text(dog.ageString)
                        }
                    }
                }
            }
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }
}

struct DogItemView_Previews: PreviewProvider {
    static var previews: some View {
        DogItemView(dog: GassiDog.current)
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
