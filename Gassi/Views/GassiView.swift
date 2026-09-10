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
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        predictionStatusImage
                    }
                    .sharedBackgroundVisibility(.hidden)
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        predictionStatusImage
                    }
                }
            }
            .navigationDestination(for: GassiEvent.self) { event in
                EventView(event: event)
            }
            .navigationTitle("GassiViewNavigationTitle")
        }
    }

    private var predictionStatusImage: some View {
        Image(systemName: navigationController.predictionStatus.symbolName)
            .foregroundStyle(navigationController.predictionStatus.color)
            .contentTransition(.symbolEffect(.replace))
            .allowsHitTesting(false)
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isImage)
            .help(navigationController.predictionStatus.message)
            .accessibilityLabel(navigationController.predictionStatus.message)
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
