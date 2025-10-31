//
//  DogSelectionView.swift
//  Gassi
//
//  Created by Jan Löffel on 22.08.22.
//

import SwiftUI

struct SettingsDogSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: CDGassiSettings

    @FetchRequest(fetchRequest: CDGassiDog.fetchSortedRequest(), animation: .default) private var dogs: FetchedResults<CDGassiDog>

    var body: some View {
        List {
            switch dogs.count {
            case 0:
                HStack {
                    Text(LocalizedStringKey("YourDog"))
                    Spacer()
                    Image(systemName: "checkmark")
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    dismiss()
                }
            case 1:
                HStack {
                    Text(settings.currentDog?.name ?? NSLocalizedString("NoName", comment: ""))
                    Spacer()
                    Image(systemName: "checkmark")
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    dismiss()
                }
            default:
                HStack {
                    Text(LocalizedStringKey("AllDogs"))
                    Spacer()
                    Image(systemName: "checkmark")
                        .isHidden(settings.currentDog != nil)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    settings.currentDog = nil
                    dismiss()
                }

                ForEach(dogs, id: \.id) { dog in
                    HStack {
                        Text(dog.name)
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .isHidden(dog != settings.currentDog)
                    }
                    .contentShape(Rectangle())
                    .tag(dog.id)
                    .onTapGesture {
                        settings.currentDog = dog
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle(LocalizedStringKey("DogsSelectionViewTitle"))
    }
}

struct SettingsDogSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsDogSelectionView()
            .environmentObject(CoreDataController.preview.settings)
    }
}
