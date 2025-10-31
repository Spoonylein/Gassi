//
//  AddGassiView.swift
//  Gassi
//
//  Created by Jan Löffel on 15.08.22.
//

import SwiftUI
import SpoonFW

struct AddGassiView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: CDGassiSettings

    @FetchRequest(fetchRequest: CDGassiCategory.fetchSortedRequest(), animation: .default) private var allGassiCategories: FetchedResults<CDGassiCategory>
    
    @EnvironmentObject private var geoController: GeoController

    var body: some View {
        VStack {
            Label(LocalizedStringKey("AddGassiTapAndHold"), systemImage: "info.circle")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            HStack {
                
                if let firstFavorite = settings.favoriteCategory1 {
                    Button {
                        
                    } label: {
                        VStack {
                            Text(firstFavorite.sign)
                                .font(.system(size: 100))
                            Text(firstFavorite.name)
                                .font(.title)
                        }
                    }
                    .simultaneousGesture(LongPressGesture().onChanged { _ in
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                    })
                    .simultaneousGesture(LongPressGesture().onEnded { _ in
                        let generator = UINotificationFeedbackGenerator()
                        addItem(gassiCategory: firstFavorite)
                        generator.notificationOccurred(.success)
                })
                } else {
                    EmptyView()
                }
                
                Spacer()
                
                Menu {
                    ForEach(allGassiCategories, id: \.id) { category in
                        Button {
                            let generator = UINotificationFeedbackGenerator()
                            addItem(gassiCategory: category)
                            generator.notificationOccurred(.success)
                        } label: {
                                Text("\(category.sign) \(category.name)")
                        }
                    }
                } label: {
                    Label("", systemImage: "ellipsis")
                        .font(.title)
                        .padding()
                } primaryAction: {
                }
                .simultaneousGesture(LongPressGesture().onChanged { _ in
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                })

                Spacer()
                
                if let secondFavorite = settings.favoriteCategory2 {
                    Button {
                        
                    } label: {
                        VStack {
                            Text(secondFavorite.sign)
                                .font(.system(size: 100))
                            Text(secondFavorite.name)
                                .font(.title)
                        }
                    }
                    .simultaneousGesture(LongPressGesture().onChanged { _ in
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    })
                    .simultaneousGesture(LongPressGesture().onEnded { _ in
                        let generator = UINotificationFeedbackGenerator()
                        addItem(gassiCategory: secondFavorite)
                        generator.notificationOccurred(.success)
                    })
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    private func addItem(timestamp: Date = .now, gassiCategory: CDGassiCategory? = nil) {
        withAnimation {
            let _ = CDGassiEvent.new(viewContext: viewContext, dog: settings.currentDog, category: gassiCategory, gracePeriod: settings.gracePeriod, latitude: geoController.location?.coordinate.latitude ?? 0, longitude: geoController.location?.coordinate.longitude ?? 0)
        }
    }

}

struct AddGassiView_Previews: PreviewProvider {
    static var previews: some View {
        AddGassiView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
            .environmentObject(CoreDataController.preview.settings)
    }
}
