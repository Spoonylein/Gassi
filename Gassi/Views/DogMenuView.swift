//
//  DogMenuView.swift
//  Gassi
//
//  Created by Jan Löffel on 22.08.22.
//

import SwiftUI

struct DogMenuView: View {
    @EnvironmentObject var settings: CDGassiSettings
    @FetchRequest(fetchRequest: CDGassiDog.fetchSortedRequest(), animation: .default) private var dogs: FetchedResults<CDGassiDog>
    
    var body: some View {
        VStack {
            if dogs.count > 1 {
                Menu {
                    ForEach(dogs) { dog in
                        Button {
                            settings.currentDog = dog
                        } label: {
                            Text(dog.name)
                        }
                        .tag(dog as CDGassiDog?)
                    }

                    Button {
                        settings.currentDog = nil
                    } label: {
                        Text(LocalizedStringKey("AllDogs"))
                    }
                    .tag(nil as CDGassiDog?)
                } label: {
                    Text(settings.currentDog?.name ?? NSLocalizedString("AllDogs", comment: ""))
                }
            }
        }
    }
}

struct DogMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DogMenuView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
            .environmentObject(CoreDataController.preview.settings)
    }
}
