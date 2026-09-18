//
//  AddGassiView.swift
//  Gassi
//
//  Created by Jan Löffel on 24.08.23.
//

import SwiftUI

struct AddGassiView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController
    @State private var saveErrorMessage: String?
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var types: FetchedResults<GassiType>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var subtypes: FetchedResults<GassiSubtype>
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    addItem(type: GassiType.poo)
                } label: {
                    VStack {
                        Text(GassiType.poo.sign ?? "")
                            .font(.system(size: 100))
                        Text(GassiType.poo.nameString)
                            .font(.title)
                    }
                }
                .buttonBorderShape(.roundedRectangle)
                .liquidGlassControl()

                Spacer()
                
                Menu {
                    ForEach(types) { type in
                        Section {
                            Button("\(type.sign ?? "") \(type.nameString)") {
                                addItem(type: type)
                            }
                            ForEach(subtypes.filter({ subtype in
                                subtype.type == type
                            })) { subtype in
                                Button("\t\(subtype.sign ?? "") \(subtype.nameString)") {
                                    addItem(type: type, subtype: subtype)
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title)
                        .padding()
                }
                .menuOrder(.fixed)
                .buttonBorderShape(.circle)
                .liquidGlassControl()
                
                Spacer()
                
                Button {
                    addItem(type: GassiType.pee)
                } label: {
                    VStack {
                        Text(GassiType.pee.sign ?? "")
                            .font(.system(size: 100))
                        Text(GassiType.pee.nameString)
                            .font(.title)
                    }
                }
                .buttonBorderShape(.roundedRectangle)
                .liquidGlassControl()
            }
        }
        .padding()
        .alert("Ereignis konnte nicht gespeichert werden", isPresented: saveErrorPresented) {
            Button("OK", role: .cancel) {
                saveErrorMessage = nil
            }
        } message: {
            if let saveErrorMessage {
                Text(saveErrorMessage)
            }
        }
    }
    
    private func addItem(type: GassiType, subtype: GassiSubtype? = nil) {
        let _ = GassiEvent.new(context: viewContext, dog: GassiDog.current, type: type, subtype: subtype)
        do {
            try viewContext.save()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            viewContext.rollback()
            saveErrorMessage = error.localizedDescription
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    private var saveErrorPresented: Binding<Bool> {
        Binding(
            get: { saveErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    saveErrorMessage = nil
                }
            }
        )
    }
}

private extension View {
    @ViewBuilder
    func liquidGlassControl() -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glass)
        } else {
            self
        }
    }
}

struct AddGassiView_Previews: PreviewProvider {
    static var previews: some View {
        AddGassiView()
            .environmentObject(NavigationController())
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
