//
//  DogView.swift
//  Gassi
//
//  Created by Jan Löffel on 31.07.23.
//

import SwiftUI

struct DogView: View {
    @ObservedObject var dog: GassiDog
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var breeds: FetchedResults<GassiBreed>

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var sexes: FetchedResults<GassiSex>

    var body: some View {
        List {
            Label {
                Text(LocalizedStringKey("Name"))
                Spacer()
                TextField(LocalizedStringKey("DogName"), text: Binding<String>.convertOptionalString($dog.name))
                    .textContentType(.givenName)
                    .multilineTextAlignment(.trailing)
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
            
            Label {
                VStack(alignment: .leading) {
                    if dog.isCurrent {
                        Text("SettingsCurrentDog")
                    } else {
                        Text("SettingsNotCurrentDog")
                        Text("Antippen zum Aktivieren.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            } icon: {
                Image(systemName: dog.isCurrent ? "checkmark.circle" : "circle")
            }
            .onTapGesture {
                GassiDog.current = dog
            }

        }
        .textFieldStyle(.roundedBorder)
        .navigationTitle(dog.name ?? localizedString("DogViewTitle"))
    }
}

struct DogView_Previews: PreviewProvider {
    static var previews: some View {
        DogView(dog: GassiDog.current)
            .environment(\.managedObjectContext, CoreDataController.shared.container.viewContext)
    }
}
