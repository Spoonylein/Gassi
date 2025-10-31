//
//  DogSelectionView.swift
//  Gassi
//
//  Created by Jan Löffel on 22.08.22.
//

import SwiftUI

struct EventDogSelectionView: View {
    @EnvironmentObject var settings: CDGassiSettings
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(fetchRequest: CDGassiDog.fetchSortedRequest(), animation: .default) private var dogs: FetchedResults<CDGassiDog>

    @ObservedObject var gassiEvent: CDGassiEvent
    
    var body: some View {
        List {
            switch dogs.count {
            case 0:
                HStack {
                    Text(LocalizedStringKey("YourDog"))
                    Spacer()
                    Image(systemName: "checkmark")
                        .isHidden(gassiEvent.dog != nil)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    gassiEvent.dog = nil
                    dismiss()
                }
            case 1:
                HStack {
                    Text(settings.currentDog?.name ?? NSLocalizedString("NoName", comment: ""))
                    Spacer()
                    Image(systemName: "checkmark")
                        .isHidden(gassiEvent.dog != settings.currentDog)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    gassiEvent.dog = settings.currentDog
                    dismiss()
                }
            default:
                HStack {
                    Text(LocalizedStringKey("AllDogs"))
                    Spacer()
                    Image(systemName: "checkmark")
                        .isHidden(gassiEvent.dog != nil)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    gassiEvent.dog = nil
                    dismiss()
                }

                ForEach(dogs, id: \.id) { dog in
                    HStack {
                        Text(dog.name)
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .isHidden(dog != gassiEvent.dog)
                    }
                    .contentShape(Rectangle())
                    .tag(dog.id)
                    .onTapGesture {
                        gassiEvent.dog = dog
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle(LocalizedStringKey("DogsSelectionViewTitle"))
    }
}

struct DogSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        EventDogSelectionView(gassiEvent: CDGassiEvent.new(viewContext: CoreDataController.preview.container.viewContext))
            .environmentObject(CoreDataController.preview.settings)
    }
}
