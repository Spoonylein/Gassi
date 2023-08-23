//
//  DogMenuView.swift
//  Gassi
//
//  Created by Jan Löffel on 23.08.23.
//

import SwiftUI

struct DogMenuView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "birthday", ascending: false)], animation: .default) private var dogs: FetchedResults<GassiDog>

    var body: some View {
        if dogs.count > 1 {
            Menu(GassiDog.current.nameString) {
                ForEach(dogs) { dog in
                    Button(dog.nameString) {
                        dog.makeCurrent()
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

struct DogMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DogMenuView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
