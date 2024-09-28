//
//  RecentEventRowView.swift
//  Gassi
//
//  Created by Jan Löffel on 14.09.22.
//

import SwiftUI

struct RecentEventRowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController
    
    @ObservedObject var type: GassiType
    
    @FetchRequest private var events: FetchedResults<GassiEvent>
    
    init(type: GassiType) {
        self.type = type
        
        _events = FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)], predicate: NSPredicate(format: "type == %@", type), animation: .default)
    }
    
    var body: some View {
        
        TimelineView(.everyMinute) { context in
            HStack {
                if let lastEvent = events.first {
                    
                    VStack(spacing: 4) {
                        Text(lastEvent.timestamp!.relativeWeekday())
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            let timeIntervalSinceLastGassi = Date.now.timeIntervalSince(lastEvent.timestamp!)
                            if timeIntervalSinceLastGassi < 60 {
                                Text("justNow")
                                    .font(.title3)
                            } else {
                                Text(TimeInterval.timeSpanString(Date.now.timeIntervalSince(lastEvent.timestamp!), academic: true, showSeconds: false, offset: 0))
                                    .font(.system(.title3, design: .monospaced))
                            }
                        }
                        .colorInvert()
                        .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                        .background(Color.accentColor)
                        .cornerRadius(5)
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                        
                        Text(lastEvent.timestamp!.formatted(date: .numeric, time: .shortened))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .background {
                        NavigationLink(value: lastEvent) {
                            EmptyView()
                        }
                    }
                    
                } else {
                    Text("NoGassiEvent ")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                VStack {
                    Text(type.sign ?? "")
                        .font(.system(size: 48.0))
                    Text(type.nameString)
                        .font(.footnote)
                }
                Spacer()
                
                if let nextEventDate = GassiEvent.nextDate(events: events.sorted(by: { event1, event2 in
                    return event1.timestamp ?? .now > event2.timestamp ?? .now
                }), eventDays: GassiEvent.daysCount(events: events)) {
                    VStack(spacing: 4) {
                        Text(nextEventDate.relativeWeekday())
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        let distanceToNextGassiEvent = Date.now.distance(to: nextEventDate)
                        if distanceToNextGassiEvent > (GassiEvent.gracePeriod * 2) {
                            Text(TimeInterval.timeSpanString(distanceToNextGassiEvent, academic: true, showSeconds: false))
                                .font(.system(.title3, design: .monospaced))
                                .foregroundColor(.primary)
                                .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                                .background(Color(uiColor: .systemFill))
                                .cornerRadius(5)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(lineWidth: 1.0)
                                }
                        } else if distanceToNextGassiEvent > 60 {
                            Text(TimeInterval.timeSpanString(distanceToNextGassiEvent, academic: true, showSeconds: false))
                                .font(.system(.title3, design: .monospaced)).bold()
                                .foregroundColor(.primary)
                                .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                                .background(Color("BadMood"))
                                .cornerRadius(5)
                                .shadow(color: Color.yellow, radius: 5.0, x: 0, y: 0)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(lineWidth: 1.0)
                                }
                            
                        } else {
                            Text("now")
                                .textCase(.uppercase)
                                .font(.title3).bold()
                                .foregroundColor(.primary)
                                .colorInvert()
                                .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                                .background(.red)
                                .cornerRadius(5)
                                .shadow(color: Color.orange, radius: 7.5, x: 0, y: 0)
                        }
                        
                        Text(nextEventDate.formatted(date: .numeric, time: .shortened))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("NoPredictionPossible")
                        .foregroundColor(.secondary)
                }
            }
            
        }
    }
}

struct RecentEventRowView_Previews: PreviewProvider {
    static var previews: some View {
        RecentEventRowView(type: GassiType.pee)
            .environmentObject(NavigationController())
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
    }
}
