//
//  GassiView.swift
//  Gassi
//
//  Created by Jan Löffel on 02.08.23.
//

import SwiftUI

struct GassiView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "birthday", ascending: false)], animation: .default) private var dogs: FetchedResults<GassiDog>

    var body: some View {
        NavigationStack {
            Text("GassiView")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        DogMenuView()
                    }
                }
                .navigationTitle(LocalizedStringKey("GassiViewNavigationTitle"))
        }
    }
}

struct GassiView_Previews: PreviewProvider {
    static var previews: some View {
        GassiView()
            .environmentObject(NavigationController())
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
