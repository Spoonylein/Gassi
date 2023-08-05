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
            } header: {
                Label(LocalizedStringKey("Subtype"), systemImage: "list.bullet.indent")
            }

            
        }
        .textFieldStyle(.roundedBorder)
        .navigationTitle(subtype.name ?? localizedString("SubtypeViewTitle"))
        .toolbar(SwiftUI.Visibility.hidden, for: SwiftUI.ToolbarPlacement.tabBar)
    }
}

struct SubtypeView_Previews: PreviewProvider {
    static var previews: some View {
        SubtypeView(subtype: GassiSubtype.hardPoo)
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
