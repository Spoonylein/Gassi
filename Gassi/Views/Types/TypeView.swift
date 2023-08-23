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
                    Text(LocalizedStringKey("TypeViewSign"))
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
                Toggle(isOn: $type.predict) {
                    Label {
                        Text(LocalizedStringKey("TypeViewPrediction"))
                            .foregroundColor(type.isPeeOrPoo ? .secondary : .primary)
                    } icon: {
                        Image(systemName: "clock.badge.questionmark")
                    }
                    
                }
                .disabled(type.isPeeOrPoo)
            } header: {
                Label(LocalizedStringKey("Events"), systemImage: "list.bullet.rectangle")
            } footer: {
                Label(LocalizedStringKey("TypeViewEventsFooter"), systemImage: "info.circle")
            }

            
            Section {
                SubtypeListView(type: type)
            } header: {
                HStack {
                    Label(LocalizedStringKey("Subtypes"), systemImage: "list.bullet.indent")
                    Spacer()
                    if (type.subtypes?.count ?? 0) > 0 {
                        EditButton()
                            .textCase(.none)
                    }
                    Button {
                        let subtype = GassiSubtype.new(context: viewContext, type: type)
                        navigationController.path.append(subtype)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            } footer: {
                if (type.subtypes?.count ?? 0) > 0 {
                    Label(LocalizedStringKey("SubtypesFooter"), systemImage: "info.circle")
                } else {
                    EmptyView()
                }
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
            } footer: {
                if type.isPeeOrPoo {
                    Label(LocalizedStringKey("TypeViewPeePooDeleteFooter"), systemImage: "info.circle")
                } else {
                    EmptyView()
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
        NavigationView {
            TypeView(type: GassiType.pee)
                .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
        }
    }
}
