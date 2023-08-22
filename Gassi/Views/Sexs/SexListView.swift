//
//  SexListView.swift
//  Gassi
//
//  Created by Jan Löffel on 02.08.23.
//

import SwiftUI

struct SexListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) private var sexs: FetchedResults<GassiSex>

    var body: some View {
        List {
            ForEach(sexs) { sex in
                NavigationLink(value: sex) {
                    SexItemView(sex: sex)
                }
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            ToolbarItem {
                EditButton()
            }
            ToolbarItem {
                Button {
                    let sex = GassiSex.new(context: viewContext)
                    navigationController.path.append(sex)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle(LocalizedStringKey("Sexes"))
        .toolbar(SwiftUI.Visibility.hidden, for: SwiftUI.ToolbarPlacement.tabBar)
    }
    
    private func deleteItems(offsets: IndexSet) {
        for offset in offsets {
            let sex = sexs[offset]
            viewContext.delete(sex)
        }
        CoreDataController.shared.save()
    }

}

struct SexListView_Previews: PreviewProvider {
    static var previews: some View {
        SexListView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
