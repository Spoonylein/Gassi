//
//  ContentView.swift
//  Gassi
//
//  Created by Jan Löffel on 19.07.23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        
        Text("WatchApp")
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
