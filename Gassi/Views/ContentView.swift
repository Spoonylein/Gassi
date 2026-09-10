//
//  ContentView.swift
//  Gassi
//
//  Created by Jan Löffel on 19.07.23.
//

import SwiftUI

struct ContentView: View {
    private enum Tabs: String {
        case gassiTab = "GassiTab"
        case eventsTab = "EventsTab"
        case settingsTab = "SettingsTab"
    }
    
    @State private var selectedTab = Tabs.gassiTab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GassiView()
                .tabItem {
                    Label("GassiTabTitle", systemImage: "pawprint.fill")
                }.tag(Tabs.gassiTab)
            
            EventsView()
                .tabItem {
                    Label("EventsTabTitle", systemImage: "list.dash")
                }.tag(Tabs.eventsTab)
            
            SettingsView()
                .tabItem {
                    Label("SettingsTabTitle", systemImage: "gearshape.fill")
                }.tag(Tabs.settingsTab)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
