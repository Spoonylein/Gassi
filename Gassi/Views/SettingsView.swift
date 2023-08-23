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

    @State private var eventsGracePeriod: TimeInterval = GassiEvent.gracePeriod
    @State private var eventsTimespan: TimeInterval = GassiEvent.timespan
    
    @State private var showResetSettingsConfirm: Bool = false
    @State private var showClearDataConfirm: Bool = false
    @State private var showRestartNeeded: Bool = false

    var body: some View {
        NavigationStack(path: $navigationController.path) {
            Form {
                
                Section {
                    DogListView(showCurrent: true)
                } header: {
                    HStack {
                        Label(LocalizedStringKey(dogs.count == 1 ? "YourDog" : "YourDogs"), systemImage: "pawprint.fill")
                        Spacer()

                        if dogs.count > 0 {
                            EditButton()
                                .textCase(.none)
                        }

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

                    Stepper(value: $eventsGracePeriod, in: 60...86400, step: 60, onEditingChanged: { value in
                        GassiEvent.gracePeriod = eventsGracePeriod
                    }) {
                        Label {
                            Text(LocalizedStringKey("SettingsGracePeriod"))
                            Text(TimeInterval.timeSpanString(GassiEvent.gracePeriod, academic: true, showSeconds: false, showNull: false, offset: 0))
                        } icon: {
                            Image(systemName: "clock.arrow.2.circlepath")
                        }
                        .onLongPressGesture {
                            eventsGracePeriod = GassiEvent.defaultGracePeriod
                            GassiEvent.gracePeriod = eventsGracePeriod
                        }
                    }

                    Stepper(value: $eventsTimespan, in: 86400...31536000, step: 86400, onEditingChanged: { value in
                        GassiEvent.timespan = eventsTimespan
                    }) {
                        Label {
                            Text(LocalizedStringKey("SettingsKeep"))
                            Text(TimeInterval.timeSpanString(GassiEvent.timespan, academic: true, showSeconds: false, showNull: false, offset: 0))
                        } icon: {
                            Image(systemName: "calendar.badge.plus")
                        }
                        .onLongPressGesture {
                            eventsTimespan = GassiEvent.defaultTimespan
                            GassiEvent.timespan = eventsTimespan
                        }
                    }

                } header: {
                    Label(LocalizedStringKey("Events"), systemImage: "calendar")
                } footer: {
                    Label(LocalizedStringKey("SettingsEventsSectionFooter"), systemImage: "info.circle")
                }

                Section {
                    Button(LocalizedStringKey("ResetSettings"), role: .destructive) {
                        showResetSettingsConfirm = true
                    }
                    .confirmationDialog(LocalizedStringKey("ResetSettings"), isPresented: $showResetSettingsConfirm) {
                        Button(LocalizedStringKey("ResetSettings"), role: .destructive) {
                            CoreDataController.shared.resetSettings()
                            showRestartNeeded = true
                        }
                    } message: {
                        Text(LocalizedStringKey("ResetSettingsConfirmationMessage"))
                    }

                    Button(LocalizedStringKey("ClearData"), role: .destructive) {
                        showClearDataConfirm = true
                    }
                    .confirmationDialog(LocalizedStringKey("ClearData"), isPresented: $showClearDataConfirm) {
                        Button(LocalizedStringKey("ClearData"), role: .destructive) {
                            CoreDataController.shared.clearData()
                            showRestartNeeded = true
                        }
                    } message: {
                        Text(LocalizedStringKey("ClearDataConfirmationMessage"))
                    }

                }
                .alert(isPresented: $showRestartNeeded) {
                    Alert(title: Text(LocalizedStringKey("RestartNeeded")), message: Text(LocalizedStringKey("RestartMessage")), dismissButton: .default(Text("OK")))
                }

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
            .navigationDestination(for: GassiSubtype.self) { subtype in
                SubtypeView(subtype: subtype)
            }
            .navigationTitle(LocalizedStringKey("Settings"))
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
