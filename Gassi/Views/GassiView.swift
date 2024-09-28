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
    
    var body: some View {
        NavigationStack(path: $navigationController.path) {
            VStack {
                RecentEventsListView()
                Spacer()
                AddGassiView()
                    .fixedSize()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    DogMenuView()
                }
            }
            .navigationDestination(for: GassiEvent.self) { event in
                EventView(event: event)
            }
            .navigationTitle("GassiViewNavigationTitle")
        }
    }
}

struct GassiView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GassiView()
                .environmentObject(NavigationController())
                .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
        }
    }
}
