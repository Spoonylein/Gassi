//
//  SettingsView.swift
//  Gassi
//
//  Created by Jan Löffel on 02.08.23.
//

import SwiftUI

import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "birthday", ascending: false)], animation: .default) private var dogs: FetchedResults<GassiDog>
    
    @State private var isPresentingConfirm: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationController.path) {
            Form {
                
                Section {
                    DogListView()
                } header: {
                    HStack {
                        Label(LocalizedStringKey(dogs.count == 1 ? "YourDog" : "YourDogs"), systemImage: "pawprint.fill")
                        Spacer()
                        Button {
                            let _ = GassiDog.new(context: viewContext)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }

                } footer: {
                    Label(LocalizedStringKey("SettingsDogSectionFooter"), systemImage: "info.circle")
                }

            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }

            .navigationDestination(for: [GassiDog].self) { dogs in
                DogListView()
            }
            .navigationDestination(for: GassiDog.self) { dog in
                DogView(dog: dog)
            }
            .navigationTitle(LocalizedStringKey("SettingsTitle"))
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(NavigationController())
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
