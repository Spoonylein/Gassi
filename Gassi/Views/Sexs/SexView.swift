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
                    Text("Name")
                    //Spacer()
                    TextField("SexName", text: Binding<String>.convertOptionalString($sex.name))
                        .textInputAutocapitalization(.never)
                        //.padding(.vertical, 5)
                } icon: {
                    Image(systemName: "square.and.pencil")
                }
            } header: {
                Label {
                    Text("Sex")
                } icon: {
                    Text("⚤")
                }
            }
            
            Section {
                DogListView(sex: sex)
            } header: {
                if (sex.dogs?.count ?? 0) > 0 {
                    Label("Dogs", systemImage: "pawprint.fill")
                }
            }
            
            Section {
                Button("DeleteSex", role: .destructive) {
                    showConfirm = true
                }
                .confirmationDialog("DeleteSex", isPresented: $showConfirm) {
                    Button("DeleteSex", role: .destructive) {
                        viewContext.delete(sex)
                        CoreDataController.shared.save()
                        navigationController.path.removeLast()
                    }
                } message: {
                    Text("DeleteSexConfirmationMessage")
                }
                
            }

        }
        .textFieldStyle(.roundedBorder)
        .navigationTitle(sex.name ?? "SexViewTitle")
        .toolbar(.hidden, for: .tabBar)
    }
}

struct SexView_Previews: PreviewProvider {
    static var previews: some View {
        SexView(sex: GassiDog.current.sex ?? GassiSex.new(context: CoreDataController.preview.container.viewContext))
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
            .environmentObject(NavigationController())
    }
}
