//
//  SubtypeListView.swift
//  Gassi
//
//  Created by Jan Löffel on 05.08.23.
//

import SwiftUI

struct SubtypeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var subtypes: FetchedResults<GassiSubtype>

    let type: GassiType
    
    @State private var showConfirm = false
    
    init(type: GassiType) {
        var typePredicate = NSPredicate(value: true)
        self.type = type
        
        typePredicate = NSPredicate(format: "type = %@", type)
        
        _subtypes = FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: typePredicate, animation: .default)
    }
    
    var body: some View {
        List {
            ForEach(subtypes) { subtype in
                NavigationLink(value: subtype) {
                    HStack {
                        SubtypeItemView(subtype: subtype)
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
//        .toolbar {
//            ToolbarItem {
//                Button {
//                    let subtype = GassiSubtype.new(context: viewContext, type: type)
//                    navigationController.path.append(subtype)
//                } label: {
//                    Image(systemName: "plus")
//                }
//            }
//        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for offset in offsets {
            let subtype = subtypes[offset]
            viewContext.delete(subtype)
        }
        CoreDataController.shared.save()
    }

}

struct SubtypeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubtypeListView(type: GassiType.poo)
                .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
                .environmentObject(NavigationController())
        }
    }
}
