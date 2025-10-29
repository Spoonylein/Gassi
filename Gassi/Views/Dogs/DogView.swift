    //
    //  DogView.swift
    //  Gassi
    //
    //  Created by Jan Löffel on 31.07.23.
    //

    import SwiftUI

    struct DogView: View {
        @Environment(\.managedObjectContext) private var viewContext
        @EnvironmentObject var navigationController: NavigationController

        @ObservedObject var dog: GassiDog

        @FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: "birthday", ascending: false)],
            animation: .default
        ) private var dogs: FetchedResults<GassiDog>

        @FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
            animation: .default
        ) private var breeds: FetchedResults<GassiBreed>

        @FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
            animation: .default
        ) private var sexes: FetchedResults<GassiSex>

        @StateObject private var oldCurrentDog: GassiDog = GassiDog.current
        @State private var showConfirm = false

        var body: some View {
            Form {
                // MARK: - Dog Info Section
                Section {
                    // Name Field
                    Label {
                        HStack(spacing: 10) {
                            Text("Name")
                            Spacer()
                            TextField(
                                "DogName",
                                text: Binding<String>.convertOptionalString($dog.name)
                            )
                            .textContentType(.givenName)
                            .padding(.vertical, 5)
                        }
                    } icon: {
                        Image(systemName: "square.and.pencil")
                    }

                    // Breed Picker
                    Picker(selection: $dog.breed) {
                        Text("Unknown").tag(nil as GassiBreed?)
                        ForEach(breeds) { breed in
                            Text(breed.name ?? "").tag(breed as GassiBreed?)
                        }
                    } label: {
                        Label {
                            Text("Breed")
                        } icon: {
                            Image(systemName: "pawprint")
                        }
                    }

                    // Sex Picker
                    Picker(selection: $dog.sex) {
                        Text("Unknown").tag(nil as GassiSex?)
                        ForEach(sexes) { sex in
                            Text(sex.nameString).tag(sex as GassiSex?)
                        }
                    } label: {
                        Label {
                            Text("Sex")
                        } icon: {
                            Text("⚤")
                        }
                    }

                    // Birthday Picker or Button
                    if dog.birthday != nil {
                        DatePicker(
                            selection: Binding<Date?>.convertOptionalValue(
                                $dog.birthday,
                                fallback: .now.addingTimeInterval(86400)
                            ),
                            displayedComponents: .date
                        ) {
                            Label {
                                Text(dog.birthday != nil ? "DogBirthDate" : "DogNoBirthDate")
                            } icon: {
                                Image(systemName: "calendar")
                            }
                        }
                    } else {
                        Button("DogNoBirthDate", systemImage: "calendar.badge.plus") {
                            dog.birthday = Date()
                        }
                        .padding(.trailing, 5)
                    }

                } header: {
                    Text("Dog")
                } footer: {
                    if dog.birthday == nil {
                        Label("DogViewDogNoBirthDate", systemImage: "info.circle")
                    }
                }

                // MARK: - Current Dog Section
                Section {
                    Label {
                        HStack {
                            Text("SettingsCurrentDog")
                            Spacer()
                            Text(GassiDog.current.nameString)
                        }
                    } icon: {
                        Image(systemName: dog.isCurrent ? "checkmark.circle" : "circle")
                    }
                    .onTapGesture {
                        if !dog.isCurrent {
                            dog.makeCurrent()
                        } else {
                            oldCurrentDog.makeCurrent()
                        }
                    }
                } footer: {
                    Label("DogViewCurrentDogFooter", systemImage: "info.circle")
                }

                // MARK: - Delete Dog Section
                Section {
                    Button("DeleteDog", role: .destructive) {
                        showConfirm = true
                    }
                    .confirmationDialog("DeleteDog", isPresented: $showConfirm) {
                        Button("DeleteDog", role: .destructive) {
                            viewContext.delete(dog)
                            CoreDataController.shared.save()
                            navigationController.path.removeLast()
                        }
                    } message: {
                        Text("DeleteDogConfirmationMessage")
                    }

                } footer: {
                    if GassiDog.current == dog {
                        Label("DogViewDeleteFooter", systemImage: "exclamationmark.triangle")
                    } else {
                        EmptyView()
                    }
                }
                .disabled(dog.isCurrent)
            }

            .textFieldStyle(.roundedBorder)
            .navigationTitle(dog.name ?? "DogViewTitle")
            .toolbar(.hidden, for: .tabBar)
        }
    }

    struct DogView_Previews: PreviewProvider {
        static var previews: some View {
            DogView(dog: GassiDog.current)
                .environment(\.managedObjectContext, CoreDataController.shared.container.viewContext)
        }
    }
