//
//  RecentEventRowView.swift
//  Gassi
//
//  Created by Jan Löffel on 14.09.22.
//

import SwiftUI
import SpoonFW

struct RecentEventRowView: View {
    @EnvironmentObject private var settings: CDGassiSettings
    
    @FetchRequest(fetchRequest: CDGassiEvent.sortedFetchRequest(ascending: false), animation: .default) private var allEvents: FetchedResults<CDGassiEvent>
    //    @FetchRequest(fetchRequest: CDGassiCategory.fetchSortedRequest(), animation: .default) private var categories: FetchedResults<CDGassiCategory>
    
    @ObservedObject var category: CDGassiCategory
    
    var body: some View {
        let events = allEvents.filter({ event in
            return (event.dog == settings.currentDog || settings.currentDog == nil || event.dog == nil) && (event.category == category)
        })
        
        TimelineView(.everyMinute) { context in
            HStack {
                if let lastEvent = events.first {
                    
                    VStack(spacing: 4) {
                        Text(lastEvent.timestamp.relativeWeekday())
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            let timeIntervalSinceLastGassi = Date.now.timeIntervalSince(lastEvent.timestamp)
                            if timeIntervalSinceLastGassi < 60 {
                                Text(LocalizedStringKey("justNow"))
                                    .font(.title3)
                            } else {
                                Text(TimeInterval.timeSpanString(Date.now.timeIntervalSince(lastEvent.timestamp), academic: true, showSeconds: false, offset: 0))
                                    .font(.system(.title3, design: .monospaced))
                            }
                        }
                        .colorInvert()
                        .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                        .background(Color.accentColor)
                        .cornerRadius(5)
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                        
                        Text(lastEvent.timestamp.formatted(date: .numeric, time: .shortened))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .background {
                        NavigationLink {
                            EventDetailsView(gassiEvent: lastEvent)
                        } label: {
                            EmptyView()
                        }
                    }
                    
                } else {
                    Text(LocalizedStringKey("NoGassiEvent"))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                Text(category.sign)
                    .font(.system(size: 48.0))
                Spacer()
                
                if let nextCategoryEventDate = CDGassiEvent.nextDate(events: events, eventDays: CDGassiEvent.daysCount(events: allEvents.filter({ item in
                    return (item.dog == settings.currentDog || settings.currentDog == nil || item.dog == nil)
                }))) {
                    VStack(spacing: 4) {
                        Text(nextCategoryEventDate.relativeWeekday())
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        let distanceToNextGassiEvent = Date.now.distance(to: nextCategoryEventDate)
                        if distanceToNextGassiEvent > (settings.gracePeriod * 2) {
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
                            Text(LocalizedStringKey("now"))
                                .font(.title3).bold()
                                .foregroundColor(.primary)
                                .colorInvert()
                                .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                                .background(.red)
                                .cornerRadius(5)
                                .shadow(color: Color.orange, radius: 7.5, x: 0, y: 0)
                        }
                        
                        Text(nextCategoryEventDate.formatted(date: .numeric, time: .shortened))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(LocalizedStringKey("NoPredictionPossible"))
                        .foregroundColor(.secondary)
                }
            }
            
        }
    }
}

struct RecentEventRowView_Previews: PreviewProvider {
    static var previews: some View {
        RecentEventRowView(category: CoreDataController.preview.settings.favoriteCategory1!)
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
            .environmentObject(CoreDataController.preview.settings)
    }
}
