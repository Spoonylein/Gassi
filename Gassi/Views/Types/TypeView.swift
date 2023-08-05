//
//  TypeView.swift
//  Gassi
//
//  Created by Jan Löffel on 05.08.23.
//

import SwiftUI

struct TypeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @ObservedObject var type: GassiType
    
    @State private var showConfirm = false

    var body: some View {
        Form {
            Section {
                Label {
                    Text(LocalizedStringKey("Name"))
                    Spacer()
                    TextField(LocalizedStringKey("TypeName"), text: Binding<String>.convertOptionalString($type.name))
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                } icon: {
                    Image(systemName: "square.and.pencil")
                }
                
                Label {
                    Text(LocalizedStringKey("Sign"))
                    Spacer()
                    TextField(LocalizedStringKey("TypeSign"), text: Binding<String>.convertOptionalString($type.sign))
                        .font(.largeTitle)
                        .frame(width: 50)
                        .padding(.vertical, 5)
                } icon: {
                    Image(systemName: "hazardsign")
                }
            } header: {
                Label(LocalizedStringKey("Type"), systemImage: "list.bullet")
            } footer: {
                Label(LocalizedStringKey("TypeSignFooter"), systemImage: "info.circle")
            }

            Section {
                Button(LocalizedStringKey("DeleteType"), role: .destructive) {
                    showConfirm = true
                }
                .confirmationDialog(LocalizedStringKey("DeleteType"), isPresented: $showConfirm) {
                    Button(LocalizedStringKey("DeleteType"), role: .destructive) {
                        viewContext.delete(type)
                        CoreDataController.shared.save()
                        navigationController.path.removeLast()
                    }
                } message: {
                    Text(LocalizedStringKey("DeleteTypeConfirmationMessage"))
                }
            }

        }
        .textFieldStyle(.roundedBorder)
        .navigationTitle(type.name ?? localizedString("TypeViewTitle"))
        .toolbar(SwiftUI.Visibility.hidden, for: SwiftUI.ToolbarPlacement.tabBar)
    }
}

struct TypeView_Previews: PreviewProvider {
    static var previews: some View {
        TypeView(type: GassiType.pee)
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
