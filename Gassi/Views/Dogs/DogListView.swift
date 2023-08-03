//
//  DogListView.swift
//  Gassi
//
//  Created by Jan Löffel on 01.08.23.
//

import SwiftUI

struct DogListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "birthday", ascending: false)], animation: .default) private var dogs: FetchedResults<GassiDog>
    
    var body: some View {
        List {
            ForEach(dogs) { dog in
                HStack {
                    Button {
                        GassiDog.current = dog
                    } label: {
                        Image(systemName: dog.isCurrent ? "checkmark.circle" : "circle")
                    }

                    ControlGroup {
                        DogItemView(dog: dog)

                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        navigationController.path.append(dog)
                    }
                }
                .deleteDisabled(dog.isCurrent)
                
            }
            .onDelete(perform: deleteItems)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for offset in offsets {
            let dog = dogs[offset]
            viewContext.delete(dog)
        }
        CoreDataController.shared.save()
    }
    
}

struct DogListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DogListView()
                .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
        }
    }
}
