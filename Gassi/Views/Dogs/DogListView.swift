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

//    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "birthday", ascending: false)], animation: .default) private var dogs: FetchedResults<GassiDog>
    
    @FetchRequest private var dogs: FetchedResults<GassiDog>
    private var showCurrent = false

    init(breed: GassiBreed? = nil, sex: GassiSex? = nil, showCurrent: Bool = false) {
        
        var breedPredicate: NSPredicate = NSPredicate(value: true)
        var sexPredicate: NSPredicate = NSPredicate(value: true)
        var predicate: NSCompoundPredicate
        
        if let _breed = breed {
            breedPredicate = NSPredicate(format: "breed = %@", _breed)
        }
        if let _sex = sex {
            sexPredicate = NSPredicate(format: "sex = %@", _sex)
        }

        predicate = NSCompoundPredicate(type: .and, subpredicates: [breedPredicate, sexPredicate])
        
        _dogs = FetchRequest(sortDescriptors: [NSSortDescriptor(key: "birthday", ascending: false)], predicate: predicate, animation: .default)
        
        self.showCurrent = showCurrent
    }
    
    var body: some View {
        List {
            ForEach(dogs) { dog in
                HStack {
                    if showCurrent {
                        Button {
                            dog.makeCurrent()
                        } label: {
                            Image(systemName: dog.isCurrent ? "checkmark.circle" : "circle")
                        }
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
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        viewContext.delete(dog)
                        CoreDataController.shared.save()
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                    
                }
                
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
