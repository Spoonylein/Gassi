//
//  MainView.swift
//  Gassi
//
//  Created by Jan Löffel on 13.08.22.
//

import SwiftUI

struct GassiView: View {

    var body: some View {
        NavigationView {
            
            VStack {
                RecentEventsView()

                DogMoodView()
                    .padding(25)
                
                Spacer()
                
                AddGassiView()
                    .padding(EdgeInsets(top: 0, leading: 25, bottom: 25, trailing: 25))
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    DogMenuView()
                }
            })
            .navigationTitle(LocalizedStringKey("GassiViewTitle"))
            
        }
        .navigationViewStyle(.stack)
    }
}

struct GassiView_Previews: PreviewProvider {
    static var previews: some View {
        GassiView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
            .environmentObject(CoreDataController.preview.settings)
    }
}
