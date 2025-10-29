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
                    Text("Name")
                    //Spacer()
                    TextField("TypeName", text: Binding<String>.convertOptionalString($type.name))
                        //.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                } icon: {
                    Image(systemName: "square.and.pencil")
                }
                
                Label {
                    Text("TypeViewSign")
                    //Spacer()
                    TextField("TypeViewSign", text: Binding<String>.convertOptionalString($type.sign), prompt: Text(" "))
                        .font(.largeTitle)
                        .frame(width: 50)
                        //.padding(.vertical, 5)
                } icon: {
                    Image(systemName: "hazardsign")
                }
            } header: {
                Label("Type", systemImage: "list.bullet")
            } footer: {
                Label("TypeSignFooter", systemImage: "info.circle")
            }
            
            Section {
                Toggle(isOn: $type.predict) {
                    Label {
                        Text("TypeViewPrediction")
                            .foregroundColor(type.isPeeOrPoo ? .secondary : .primary)
                    } icon: {
                        Image(systemName: "clock.badge.questionmark")
                    }
                    
                }
                .disabled(type.isPeeOrPoo)
            } header: {
                Label("Events", systemImage: "list.bullet.rectangle")
            } footer: {
                Label("TypeViewEventsFooter", systemImage: "info.circle")
            }

            
            Section {
                SubtypeListView(type: type)
            } header: {
                HStack {
                    Label("Subtypes", systemImage: "list.bullet.indent")
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
                    VStack(alignment: .leading) {
                        Label("SubtypesFooter", systemImage: "info.circle")
                        Label("SubtypesPredictionFooter", systemImage: "exclamationmark.triangle")
                    }
                } else {
                    EmptyView()
                }
            }
            
            Section {
                Button("DeleteType", role: .destructive) {
                    showConfirm = true
                }
                .confirmationDialog("DeleteType", isPresented: $showConfirm) {
                    Button("DeleteType", role: .destructive) {
                        viewContext.delete(type)
                        CoreDataController.shared.save()
                        navigationController.path.removeLast()
                    }
                } message: {
                    Text("DeleteTypeConfirmationMessage")
                }
            } footer: {
                if type.isPeeOrPoo {
                    Label("TypeViewPeePooDeleteFooter", systemImage: "info.circle")
                } else {
                    EmptyView()
                }
            }
            
        }
        .textFieldStyle(.roundedBorder)
        .navigationTitle(type.name ?? "TypeViewTitle")
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
