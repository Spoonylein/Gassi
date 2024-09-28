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
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var types: FetchedResults<GassiType>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var subtypes: FetchedResults<GassiSubtype>
    
    var body: some View {
        VStack {
            Label("AddGassiTapAndHold", systemImage: "info.circle")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            HStack {
                Button {
                } label: {
                    VStack {
                        Text(GassiType.poo.sign ?? "")
                            .font(.system(size: 100))
                        Text(GassiType.poo.nameString)
                            .font(.title)
                    }
                }
                .simultaneousGesture(LongPressGesture().onChanged { _ in
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                })
                .simultaneousGesture(LongPressGesture().onEnded { _ in
                    let generator = UINotificationFeedbackGenerator()
                    addItem(type: GassiType.poo)
                    generator.notificationOccurred(.success)
                })
                
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
                } primaryAction: { }
                .simultaneousGesture(LongPressGesture().onChanged { _ in
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                })
                .menuOrder(.fixed)
                                
                Spacer()
                
                Button {
                } label: {
                    VStack {
                        Text(GassiType.pee.sign ?? "")
                            .font(.system(size: 100))
                        Text(GassiType.pee.nameString)
                            .font(.title)
                    }
                }
                .simultaneousGesture(LongPressGesture().onChanged { _ in
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                })
                .simultaneousGesture(LongPressGesture().onEnded { _ in
                    let generator = UINotificationFeedbackGenerator()
                    addItem(type: GassiType.pee)
                    generator.notificationOccurred(.success)
                })
            }
        }
        .padding()
    }
    
    private func addItem(type: GassiType, subtype: GassiSubtype? = nil) {
        let _ = GassiEvent.new(context: viewContext, dog: GassiDog.current, type: type, subtype: subtype)
    }
}

struct AddGassiView_Previews: PreviewProvider {
    static var previews: some View {
        AddGassiView()
            .environmentObject(NavigationController())
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
