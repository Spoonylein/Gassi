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
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "birthday", ascending: false)], animation: .default) private var dogs: FetchedResults<GassiDog>

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var breeds: FetchedResults<GassiBreed>

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var sexes: FetchedResults<GassiSex>

    @StateObject private var oldCurrentDog: GassiDog = GassiDog.current
    @State private var showConfirm = false
    
    var body: some View {
        Form {
            Section {
                Label {
                    Text(LocalizedStringKey("Name"))
                    Spacer()
                    TextField(LocalizedStringKey("DogName"), text: Binding<String>.convertOptionalString($dog.name))
                        .textContentType(.givenName)
                        .padding(.vertical, 5)
                } icon: {
                    Image(systemName: "square.and.pencil")
                }

                Picker(selection: $dog.breed) {
                    Text(LocalizedStringKey("Unknown"))
                        .tag(nil as GassiBreed?)
                    ForEach(breeds) { breed in
                        Text(breed.name ?? "")
                            .tag(breed as GassiBreed?)
                    }
                } label: {
                    Label {
                        Text(LocalizedStringKey("Breed"))
                    } icon: {
                        Image(systemName: "pawprint")
                    }
                }

                Picker(selection: $dog.sex) {
                    Text(LocalizedStringKey("Unknown"))
                        .tag(nil as GassiSex?)
                    ForEach(sexes) { sex in
                            Text(sex.nameString)
                                .tag(sex as GassiSex?)
                    }
                } label: {
                    Label {
                        Text(LocalizedStringKey("Sex"))
                    } icon: {
                        Text("⚤")
                    }
                }
                
                DatePicker(selection: Binding<Date?>.convertOptionalValue($dog.birthday, fallback: .now.addingTimeInterval(86400)), displayedComponents: .date) {

                    Label {
                        Text(dog.birthday != nil ? LocalizedStringKey("DogBirthDate") : LocalizedStringKey("DogNoBirthDate"))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                }
            } header: {
                Text(LocalizedStringKey("Dog"))
            }
            
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
                Label(LocalizedStringKey("DogViewCurrentDogFooter"), systemImage: "info.circle")
            }
            
            Section {
                Button(LocalizedStringKey("DeleteDog"), role: .destructive) {
                    showConfirm = true
                }
                .confirmationDialog(LocalizedStringKey("DeleteDog"), isPresented: $showConfirm) {
                    Button(LocalizedStringKey("DeleteDog"), role: .destructive) {
                        viewContext.delete(dog)
                        CoreDataController.shared.save()
                        navigationController.path.removeLast()
                    }
                } message: {
                    Text(LocalizedStringKey("DeleteDogConfirmationMessage"))
                }
                
            } footer: {
                if GassiDog.current == dog {
                    Label(LocalizedStringKey("DogViewDeleteFooter"), systemImage: "exclamationmark.triangle")
                } else {
                    EmptyView()
                }
            }
            .disabled(dog.isCurrent)

        }
        .textFieldStyle(.roundedBorder)
        .navigationTitle(dog.name ?? localizedString("DogViewTitle"))
        .toolbar(SwiftUI.Visibility.hidden, for: SwiftUI.ToolbarPlacement.tabBar)
    }
}

struct DogView_Previews: PreviewProvider {
    static var previews: some View {
        DogView(dog: GassiDog.current)
            .environment(\.managedObjectContext, CoreDataController.shared.container.viewContext)
    }
}
