//
//  BreedView.swift
//  Gassi
//
//  Created by Jan Löffel on 04.08.23.
//

import SwiftUI

struct BreedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @ObservedObject var breed: GassiBreed

    @State private var showConfirm = false

    var body: some View {
        Form {
            Section {
                Label {
                    Text(LocalizedStringKey("Name"))
                    Spacer()
                    TextField(LocalizedStringKey("BreedName"), text: Binding<String>.convertOptionalString($breed.name))
                        .padding(.vertical, 5)
                } icon: {
                    Image(systemName: "square.and.pencil")
                }
            } header: {
                Label(LocalizedStringKey("Breed"), systemImage: "pawprint")
            }
            
            Section {
                DogListView(breed: breed)
            } header: {
                if (breed.dogs?.count ?? 0) > 0 {
                    Label(LocalizedStringKey("Dogs"), systemImage: "pawprint.fill")
                }
            }
            
            Section {
                Button(LocalizedStringKey("DeleteBreed"), role: .destructive) {
                    showConfirm = true
                }
                .confirmationDialog(LocalizedStringKey("DeleteBreed"), isPresented: $showConfirm) {
                    Button(LocalizedStringKey("DeleteBreed"), role: .destructive) {
                        viewContext.delete(breed)
                        CoreDataController.shared.save()
                        navigationController.path.removeLast()
                    }
                } message: {
                    Text(LocalizedStringKey("DeleteBreedConfirmationMessage"))
                }
                
            }

        }
        .textFieldStyle(.roundedBorder)
        .navigationTitle(breed.name ?? localizedString("BreedViewTitle"))
        .toolbar(SwiftUI.Visibility.hidden, for: SwiftUI.ToolbarPlacement.tabBar)
    }
}

struct BreedView_Previews: PreviewProvider {
    static var previews: some View {
        BreedView(breed: GassiDog.current.breed ?? GassiBreed.new(context: CoreDataController.preview.container.viewContext))
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
        
    }
}
