//
//  SexView.swift
//  Gassi
//
//  Created by Jan Löffel on 04.08.23.
//

import SwiftUI

struct SexView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @ObservedObject var sex: GassiSex

    @State private var showConfirm = false

    var body: some View {
        Form {
            Section {
                Label {
                    Text(LocalizedStringKey("Name"))
                    Spacer()
                    TextField(LocalizedStringKey("SexName"), text: Binding<String>.convertOptionalString($sex.name))
                        .textInputAutocapitalization(.never)
                } icon: {
                    Image(systemName: "square.and.pencil")
                }
            } header: {
                Text(LocalizedStringKey("Sex"))
            }
            
            Section {
                DogListView(sex: sex)
            } header: {
                if (sex.dogs?.count ?? 0) > 0 {
                    Label(LocalizedStringKey("Dogs"), systemImage: "pawprint.fill")
                }
            }
            
            Section {
                Button(LocalizedStringKey("DeleteSex"), role: .destructive) {
                    showConfirm = true
                }
                .confirmationDialog(LocalizedStringKey("DeleteSex"), isPresented: $showConfirm) {
                    Button(LocalizedStringKey("DeleteSex"), role: .destructive) {
                        viewContext.delete(sex)
                        CoreDataController.shared.save()
                        navigationController.path.removeLast()
                    }
                } message: {
                    Text(LocalizedStringKey("DeleteSexConfirmationMessage"))
                }
                
            }

        }
        .textFieldStyle(.roundedBorder)
        .navigationTitle(sex.name ?? localizedString("SexViewTitle"))

    }
}

struct SexView_Previews: PreviewProvider {
    static var previews: some View {
        SexView(sex: GassiDog.current.sex ?? GassiSex.new(context: CoreDataController.preview.container.viewContext))
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
        
    }
}
