//
//  EventView.swift
//  Gassi
//
//  Created by Jan Löffel on 05.08.23.
//

import SwiftUI

struct EventView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController

    @ObservedObject var event: GassiEvent

    @State private var showConfirm = false

    var body: some View {
        Form {
            Section {
                EventDogPickerView(event: event)
                TypePickerView(event: event)
                EventSubtypePickerView(event: event, type: event.type)
                    .disabled(event.type?.subtypes?.count == 0)
            } header: {
                Label(LocalizedStringKey("EventFeatureSectionTitle"), systemImage: "rectangle.and.text.magnifyingglass")
            }
            .onChange(of: event.type) { newValue in
                event.subtype = nil
            }
            
            Section {
                DatePicker(selection: Binding<Date?>.convertOptionalValue($event.timestamp, fallback: .now), displayedComponents: [.date, .hourAndMinute]) {
                    Label(LocalizedStringKey("Timestamp"), systemImage: "calendar")
                }
            } header: {
                Label(LocalizedStringKey("EventViewTimeAndPlace"), systemImage: "clock")
            }
            
            Section {
                Button(LocalizedStringKey("DeleteEvent"), role: .destructive) {
                    showConfirm = true
                }
                .confirmationDialog(LocalizedStringKey("DeleteEvent"), isPresented: $showConfirm) {
                    Button(LocalizedStringKey("DeleteEvent"), role: .destructive) {
                        viewContext.delete(event)
                        CoreDataController.shared.save()
                        navigationController.path.removeLast()
                    }
                } message: {
                    Text(LocalizedStringKey("DeleteEventConfirmationMessage"))
                }
            }
        }
        .navigationTitle(LocalizedStringKey("EditEvent"))
        .toolbar(SwiftUI.Visibility.hidden, for: SwiftUI.ToolbarPlacement.tabBar)
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventView(event: GassiEvent.new(context: CoreDataController.preview.container.viewContext, dog: GassiDog.current, type: GassiType.pee))
                .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
                .environmentObject(NavigationController())
        }
    }
}
