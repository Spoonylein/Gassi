//
//  DogDetailsView.swift
//  Gassi
//
//  Created by Jan Löffel on 21.08.22.
//

import SwiftUI

struct DogDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(fetchRequest: CDGassiEvent.sortedFetchRequest(), animation: .default) private var events: FetchedResults<CDGassiEvent>

    // TODO: Binding instead of @ObservedObject
    @ObservedObject var dog: CDGassiDog
        
    var body: some View {
        Form {
            List {

                Section {
                    Label {
                        Text(LocalizedStringKey("DogName"))
                        Spacer()
                        TextField(LocalizedStringKey("DogName"), text: $dog.name)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.accentColor)
                            .textFieldStyle(.roundedBorder)
                    } icon: {
                        Image(systemName: "square.and.pencil")
                    }
                    
                    Label {
                        DatePicker(LocalizedStringKey("DogBirthDate"), selection: Binding<Date>.convertOptionalValue($dog.birthDate, fallback: .now), in: ...Date.now, displayedComponents: .date)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    
                } header: {
                    Label(LocalizedStringKey("DogDetailsNameBirthSectionHeader"), systemImage: "doc.plaintext.fill")
                } footer: {
                    Label(LocalizedStringKey("DogDetailsNameBirthSectionFooter"), systemImage: "info.circle")
                }

                Section {
                    Label {
                        Text(LocalizedStringKey("DogBreed"))
                        Spacer()
                        TextField(LocalizedStringKey("DogBreed"), text: $dog.breed)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.accentColor)
                            .textFieldStyle(.roundedBorder)
                    } icon: {
                        Image(systemName: "pawprint")
                    }
                } header: {
                    Label(LocalizedStringKey("DogDetailsBreedSectionHeader"), systemImage: "pawprint.fill")
                } footer: {
                    Label(LocalizedStringKey("DogDetailsBreedSectionFooter"), systemImage: "info.circle")
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    for event in events.filter({ event in
                        return event.dog == dog
                    }) {
                        event.dog = nil
                    }
                    viewContext.delete(dog)
                    dismiss()
                } label: {
                    Label(LocalizedStringKey("Delete"), systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(LocalizedStringKey("DogDetailsViewTitle"))
    }
}

struct DogDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let dog = CDGassiDog.new(viewContext: CoreDataController.preview.container.viewContext)
        NavigationView {
            DogDetailsView(dog: dog)
        }
    }
}
