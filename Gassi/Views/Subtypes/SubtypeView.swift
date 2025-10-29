//
//  SubtypeView.swift
//  Gassi
//
//  Created by Jan Löffel on 05.08.23.
//

import SwiftUI

struct SubtypeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @ObservedObject var subtype: GassiSubtype
    
    @State private var showConfirm = false

    var body: some View {
        Form {
            Section {
                Label {
                    Text("Name")
                    //Spacer()
                    TextField("SubtypeName", text: Binding<String>.convertOptionalString($subtype.name))
                        //.padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 0))
                } icon: {
                    Image(systemName: "square.and.pencil")
                }
                
                Label {
                    Text("SubtypeViewSign")
                    //Spacer()
                    TextField("SubtypeViewSign", text: Binding<String>.convertOptionalString($subtype.sign), prompt: Text(" "))
                        .font(.largeTitle)
                        .frame(width: 50)
                        //.padding(.vertical, 5)
                } icon: {
                    Image(systemName: "hazardsign")
                }
            } header: {
                Label("Subtype", systemImage: "list.bullet.indent")
            } footer: {
                Label("SubtypeSignFooter", systemImage: "info.circle")
            }

            Section {
                Button("DeleteSubtype", role: .destructive) {
                    showConfirm = true
                }
                .confirmationDialog("DeleteSubtype", isPresented: $showConfirm) {
                    Button("DeleteSubtype", role: .destructive) {
                        viewContext.delete(subtype)
                        CoreDataController.shared.save()
                        navigationController.path.removeLast()
                    }
                } message: {
                    Text("DeleteSubtypeConfirmationMessage")
                }
            } 
        }
        .textFieldStyle(.roundedBorder)
        .navigationTitle(subtype.name ?? "SubtypeViewTitle")
        .toolbar(SwiftUI.Visibility.hidden, for: SwiftUI.ToolbarPlacement.tabBar)
    }
}

struct SubtypeView_Previews: PreviewProvider {
    static var previews: some View {
        let hardPoo = GassiSubtype.newHardPoo(context: CoreDataController.preview.container.viewContext)
        NavigationView {
            SubtypeView(subtype: hardPoo)
                .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
            .environmentObject(NavigationController())
        }
    }
}
