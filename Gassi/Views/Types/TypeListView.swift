//
//  TypeListView.swift
//  Gassi
//
//  Created by Jan Löffel on 05.08.23.
//

import SwiftUI

struct TypeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var types: FetchedResults<GassiType>

    var body: some View {
        List {
            ForEach(types) { type in
                NavigationLink(value: type) {
                    TypeItemView(type: type)
                }
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    let type = GassiType.new(context: viewContext)
                    navigationController.path.append(type)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle(LocalizedStringKey("Types"))
            .toolbar(SwiftUI.Visibility.hidden, for: SwiftUI.ToolbarPlacement.tabBar)
    }
    
    private func deleteItems(offsets: IndexSet) {
        for offset in offsets {
            let type = types[offset]
            viewContext.delete(type)
        }
        CoreDataController.shared.save()
    }

}

struct TypeListView_Previews: PreviewProvider {
    static var previews: some View {
        TypeListView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
