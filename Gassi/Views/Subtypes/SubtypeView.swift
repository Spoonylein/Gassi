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
                    Text(LocalizedStringKey("Name"))
                    Spacer()
                    TextField(LocalizedStringKey("SubtypeName"), text: Binding<String>.convertOptionalString($subtype.name))
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 0))
                } icon: {
                    Image(systemName: "square.and.pencil")
                }
                
                Label {
                    Text(LocalizedStringKey("SubtypeViewSign"))
                    Spacer()
                    TextField(LocalizedStringKey("SubtypeViewSign"), text: Binding<String>.convertOptionalString($subtype.sign), prompt: Text(""))
                        .font(.largeTitle)
                        .frame(width: 50)
                        .padding(.vertical, 5)
                } icon: {
                    Image(systemName: "hazardsign")
                }
            } header: {
                Label(LocalizedStringKey("Subtype"), systemImage: "list.bullet.indent")
            } footer: {
                Label(LocalizedStringKey("SubtypeSignFooter"), systemImage: "hazardsign")
            }

            Section {
                Button(LocalizedStringKey("DeleteSubtype"), role: .destructive) {
                    showConfirm = true
                }
                .confirmationDialog(LocalizedStringKey("DeleteSubtype"), isPresented: $showConfirm) {
                    Button(LocalizedStringKey("DeleteSubtype"), role: .destructive) {
                        viewContext.delete(subtype)
                        CoreDataController.shared.save()
                        navigationController.path.removeLast()
                    }
                } message: {
                    Text(LocalizedStringKey("DeleteSubtypeConfirmationMessage"))
                }
            } 
        }
        .textFieldStyle(.roundedBorder)
        .navigationTitle(subtype.name ?? localizedString("SubtypeViewTitle"))
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
