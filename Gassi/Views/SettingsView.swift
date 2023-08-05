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
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var breeds: FetchedResults<GassiBreed>

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var sexes: FetchedResults<GassiSex>

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var types: FetchedResults<GassiType>

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var subtypes: FetchedResults<GassiSubtype>

    @State private var isPresentingConfirm: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationController.path) {
            Form {
                
                Section {
                    DogListView(showCurrent: true)
                } header: {
                    HStack {
                        Label(LocalizedStringKey(dogs.count == 1 ? "YourDog" : "YourDogs"), systemImage: "pawprint.fill")
                        Spacer()
                        Button {
                            let dog = GassiDog.new(context: viewContext)
                            navigationController.path.append(dog)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }

                } footer: {
                    Label(LocalizedStringKey("SettingsDogSectionFooter"), systemImage: "info.circle")
                }

                Section {
                    NavigationLink(value: [GassiBreed()]) {
                        Label {
                            HStack {
                                Text(LocalizedStringKey("Breeds"))
                                Spacer()
                                Text("\(breeds.count)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "pawprint")
                        }
                    }

                    NavigationLink(value: [GassiSex()]) {
                        Label {
                            HStack {
                                Text(LocalizedStringKey("Sexes"))
                                Spacer()
                                Text("\(sexes.count)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Text("⚤")
                        }
                    }
                } header: {
                        Label(LocalizedStringKey("SettingsFeatureSectionTitle"), systemImage: "rectangle.and.text.magnifyingglass")
                }
                
                Section {
                    NavigationLink(value: [GassiType()]) {
                        Label {
                            HStack {
                                Text(LocalizedStringKey("Types"))
                                Spacer()
                                Text("\(types.count)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "list.bullet")
                        }

                    }

                    NavigationLink(value: [GassiSubtype()]) {
                        Label {
                            HStack {
                                Text(LocalizedStringKey("Subtypes"))
                                Spacer()
                                Text("\(subtypes.count)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "list.bullet.indent")
                        }

                    }

                    Label("Karenzzeit", systemImage: "clock.arrow.2.circlepath")
                    Label("Behalte x Tage", systemImage: "calendar.badge.plus")
                } header: {
                    Label(LocalizedStringKey("Events"), systemImage: "calendar")
                }


            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                }
            }

            .navigationDestination(for: [GassiDog].self) { dogs in
                DogListView()
            }
            .navigationDestination(for: GassiDog.self) { dog in
                DogView(dog: dog)
            }
            .navigationDestination(for: [GassiBreed].self) { breeds in
                BreedListView()
            }
            .navigationDestination(for: GassiBreed.self) { breed in
                BreedView(breed: breed)
            }
            .navigationDestination(for: [GassiSex].self) { sexes in
                SexListView()
            }
            .navigationDestination(for: GassiSex.self) { sex in
                SexView(sex: sex)
            }
            .navigationDestination(for: [GassiType].self) { types in
                TypeListView()
            }
            .navigationDestination(for: GassiType.self) { type in
                TypeView(type: type)
            }
            .navigationDestination(for: [GassiSubtype].self) { subtypes in
                SubtypeListView()
            }
            .navigationDestination(for: GassiSubtype.self) { subtype in
                SubtypeView(subtype: subtype)
            }
            .navigationDestination(for: [GassiEvent].self) { events in
                EventListView()
            }
            .navigationDestination(for: GassiEvent.self) { event in
                EventView(event: event)
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
