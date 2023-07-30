//
//  ContentView.swift
//  Gassi
//
//  Created by Jan Löffel on 19.07.23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \GassiEvent.timestamp, ascending: true)],
//        animation: .default)
//    private var events: FetchedResults<GassiEvent>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GassiDog.birthday, ascending: true)],
        animation: .default)
    private var dogs: FetchedResults<GassiDog>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dogs) { dog in
                    HStack {
                        if GassiDog.current == dog {
                            Text(">")
                        }
                        Text(dog.name ?? "no dog name")
                    }
                    .onTapGesture {
                        GassiDog.current = dog
                    }
                }
                .onDelete(perform: deleteDogs)
                
//                ForEach(events) { event in
//                    NavigationLink {
//                        Text("Item at \(event.timestamp!, formatter: itemFormatter)")
//                    } label: {
//                        Text(event.timestamp!, formatter: itemFormatter)
//                        Text(event.dog?.name ?? "no name")
//                        Text(event.type?.name ?? "no name")
//                        Text(event.subtype?.name ?? "")
//                    }
//                }
//                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
#if os(iOS)
                    EditButton()
#endif
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = GassiEvent.new(context: viewContext, dog: GassiDog.current, type: GassiType.pee)
            
            CoreDataController.shared.save()
        }
    }
    
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { events[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
    
    private func deleteDogs(offsets: IndexSet) {
        withAnimation {
            offsets.map { dogs[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
