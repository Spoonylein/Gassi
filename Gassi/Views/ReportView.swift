//
//  ReportView.swift
//  Gassi
//
//  Created by Jan Löffel on 13.08.22.
//

import SwiftUI
import Charts
import SpoonFW

struct ReportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: CDGassiSettings
    
    @FetchRequest(fetchRequest: CDGassiEvent.sortedFetchRequest(), animation: .default) private var events: FetchedResults<CDGassiEvent>
    @FetchRequest(fetchRequest: CDGassiCategory.fetchSortedRequest(), animation: .default) private var categories: FetchedResults<CDGassiCategory>
    
    @State private var category: CDGassiCategory? = nil
    
    var body: some View {
        NavigationView {
            List {
                if events.count > 1 {
                    
                    Section(LocalizedStringKey("ReportViewSummarySectionHeader")) {
                        let daysCount = CDGassiEvent.daysCount(events: events)
                        
                        Label {
                            Text(LocalizedStringKey("ReportViewTimespan"))
                            Spacer()
                            Text(events.first?.timestamp.formatted(date: .numeric, time: .omitted) ?? "")
                            Text("-")
                            Text(events.last?.timestamp.formatted(date: .numeric, time: .omitted) ?? "")
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        
                        Label {
                            Text(LocalizedStringKey("ReportViewEventDays"))
                            Spacer()
                            Text(daysCount.formatted())
                            Text("/")
                                .foregroundColor(.secondary)
                            Text(Int(Calendar.current.startOfDay(for: events.first!.timestamp).distance(to: Calendar.current.startOfDay(for: events.last!.timestamp)) / 86400 + 1).formatted())
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "number.square")
                        }
                        
                        DayDistributionView(events: events)
                    }
                    
                    Section(LocalizedStringKey("ReportViewByCategorySectionHeader")) {
                        Label {
                            Picker(LocalizedStringKey("EventsListViewCategoryFilter"), selection: $category) {
                                Text(LocalizedStringKey("EventsListViewAllCategories"))
                                    .tag(nil as CDGassiCategory?)
                                ForEach(categories, id: \.id) { category in
                                    Text("\(category.sign) \(category.name)")
                                        .tag(category as CDGassiCategory?)
                                }
                            }
                            .pickerStyle(.menu)
                        } icon: {
                            Image(systemName: "folder")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Label {
                            Text(LocalizedStringKey("ReportViewEventCountByCategory"))
                            Spacer()
                            Text(category?.events.count.formatted() ?? events.count.formatted())
                        } icon: {
                            Image(systemName: "number")
                        }
                        
                        EventCountPerCategoryView(category: category)

                        EventDistancePerCategoryView(category: category)
                    }
                } else {
                    Text(LocalizedStringKey("ReportViewNotEnoughData"))
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem {
                    DogMenuView()
                }
            }
            .navigationTitle(LocalizedStringKey("ReportViewTitle"))
        }
        .navigationViewStyle(.stack)
    }
}

struct DayDistributionView: View {
    let events: FetchedResults<CDGassiEvent>
    
    var body: some View {
        VStack {
            Label {
                Text(LocalizedStringKey("ReportViewDayDistribution"))
                Spacer()
            } icon: {
                Image(systemName: "aqi.medium")
            }
            
            
            Chart(events) { event in
                let secondsOnDay = Calendar.current.startOfDay(for: event.timestamp).distance(to: event.timestamp)
                PointMark(x: .value("", Calendar.current.startOfDay(for: .now).addingTimeInterval(secondsOnDay)),
                          y: .value("", events.firstIndex(of: event)!))
                .symbolSize(5)
                .foregroundStyle(by: .value("", event.category?.name ?? ""))
            }
            .chartXScale(domain: Calendar.current.startOfDay(for: .now)...Calendar.current.startOfDay(for: .now).addingTimeInterval(86400))
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .hour, count: 6, calendar: .current))
            }
            .chartYAxis(.hidden)
            .frame(height: 75.0)
            .padding(.horizontal)
        }
    }
}

struct EventCountPerCategoryView: View {
    
    @FetchRequest(fetchRequest: CDGassiEvent.sortedFetchRequest(), animation: .default) private var events: FetchedResults<CDGassiEvent>
    let category: CDGassiCategory?
    
    var body: some View {
        let categoryEvents = events.filter { event in
            return event.category == category || category == nil
        }
        let eventsPerDayCount = CDGassiEvent.eventsPerDayCount(events: categoryEvents)
        let maxEventsPerDay = CDGassiEvent.maxEventsCount(events: CDGassiEvent.eventsArray(events: events))
        let maxEventsPerDayAndCategory = CDGassiEvent.maxEventsCount(events: categoryEvents)
        let minEventsPerDayAndCategory = CDGassiEvent.minEventsCount(events: categoryEvents)
        let categoryEventDays = CDGassiEvent.eventDays(events: categoryEvents)
        let allEventDays = CDGassiEvent.eventDays(events: CDGassiEvent.eventsArray(events: events))
        
        VStack(alignment: .leading) {
            Label {
                Text(LocalizedStringKey("ReportViewEventsPerDayByCategory"))
            } icon: {
                Image(systemName: "number.circle")
            }

            Chart(categoryEventDays, id:\.self) { day in
                let eventCount = eventsPerDayCount[day]
                BarMark(x: .value("X", day),
                        y: .value("Y", eventCount ?? 0),
                        width: .automatic)
                .foregroundStyle(eventCount == maxEventsPerDayAndCategory.eventCount ? .red : eventCount == minEventsPerDayAndCategory.eventCount ? .green : .accentColor)
            }
            .chartXScale(domain: allEventDays.first!...allEventDays.last!)
            .chartXAxis {
                AxisMarks(preset: .aligned) { value in
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day(.defaultDigits))
                }
            }
            .chartYScale(domain: 0...maxEventsPerDay.eventCount)
            .chartYAxis {
                AxisMarks(preset: .aligned) {
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 100.0)
            .padding(.horizontal)
            
            HStack(alignment: .top) {
                VStack {
                    if category?.events == nil {
                        let minEventsPerDay = CDGassiEvent.minEventsCount(events: CDGassiEvent.eventsArray(events: events))
                        HStack(alignment: .bottom) {
                            Text(LocalizedStringKey("ReportViewMinEventsPerDayByCategory"))
                            Text(minEventsPerDay.eventCount.formatted())
                                .font(.body)
                                .foregroundColor(.primary)
                                .colorInvert()
                                .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                                .background(.green)
                                .cornerRadius(5)
                        }
                        Text(minEventsPerDay.day.formatted(date: .numeric, time: .omitted))
                    } else {
                        let minEventsPerDay = CDGassiEvent.minEventsCount(events: category!.events.allObjects as! [CDGassiEvent])
                        HStack(alignment: .bottom) {
                            Text(LocalizedStringKey("ReportViewMinEventsPerDayByCategory"))
                            Text(minEventsPerDay.eventCount.formatted())
                                .font(.body)
                                .foregroundColor(.primary)
                                .colorInvert()
                                .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                                .background(.green)
                                .cornerRadius(5)
                        }
                        Text(minEventsPerDay.day.formatted(date: .numeric, time: .omitted))
                    }
                }
                Spacer()
                VStack {
                    if category?.events == nil {
                        let daysCount = CDGassiEvent.daysCount(events: events)
                        HStack(alignment: .bottom) {
                            Text(LocalizedStringKey("ReportViewAvgEventsPerDayByCategory"))
                            Text(String(format: "%.0f", (Double(events.count) / Double(max(1, daysCount)))))
                                .font(.body)
                                .foregroundColor(.primary)
                                .colorInvert()
                                .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                                .background(.tint)
                                .cornerRadius(5)
                        }
                    } else {
                        let daysCount = CDGassiEvent.daysCount(events: category!.events.allObjects as! [CDGassiEvent])
                        HStack(alignment: .bottom) {
                            Text(LocalizedStringKey("ReportViewAvgEventsPerDayByCategory"))
                            Text(String(format: "%.0f", (Double(category!.events.count) / Double(max(1, daysCount)))))
                                .font(.body)
                                .foregroundColor(.primary)
                                .colorInvert()
                                .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                                .background(.tint)
                                .cornerRadius(5)
                        }
                    }
                }
                Spacer()
                VStack() {
                    if category?.events == nil {
                        let maxEventsPerDay = CDGassiEvent.maxEventsCount(events: CDGassiEvent.eventsArray(events: events))
                        HStack(alignment: .bottom) {
                            Text(LocalizedStringKey("ReportViewMaxEventsPerDayByCategory"))
                            Text(maxEventsPerDay.eventCount.formatted())
                                .font(.body)
                                .foregroundColor(.primary)
                                .colorInvert()
                                .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                                .background(.red)
                                .cornerRadius(5)
                        }
                        Text(maxEventsPerDay.day.formatted(date: .numeric, time: .omitted))
                    } else {
                        let maxEventsPerDay = CDGassiEvent.maxEventsCount(events: category!.events.allObjects as! [CDGassiEvent])
                        HStack(alignment: .bottom) {
                            Text(LocalizedStringKey("ReportViewMaxEventsPerDayByCategory"))
                            Text(maxEventsPerDay.eventCount.formatted())
                                .font(.body)
                                .foregroundColor(.primary)
                                .colorInvert()
                                .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                                .background(.red)
                                .cornerRadius(5)
                        }
                        Text(maxEventsPerDay.day.formatted(date: .numeric, time: .omitted))
                    }
                }
            }
            .multilineTextAlignment(.center)
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding()
        }
    }
}

struct EventDistancePerCategoryView: View {
    
    @FetchRequest(fetchRequest: CDGassiEvent.sortedFetchRequest(), animation: .default) private var events: FetchedResults<CDGassiEvent>
    let category: CDGassiCategory?
    
    var body: some View {
        let categoryEvents = events.filter { event in
            return (event.category == category || category == nil)
        }
        let categoryEventDays = CDGassiEvent.eventDays(events: categoryEvents)
        let allEventDays = CDGassiEvent.eventDays(events: CDGassiEvent.eventsArray(events: events))
        let minDistancePerDay = CDGassiEvent.minDistancePerDay(events: categoryEvents)
        let maxDistancePerDay = CDGassiEvent.maxDistancePerDay(events: categoryEvents)
        let maxDistance = CDGassiEvent.maxDistance(events: categoryEvents)
        let minDistance = CDGassiEvent.minDistance(events: categoryEvents)

        VStack(alignment: .leading) {
            Label {
                Text(LocalizedStringKey("ReportViewDistancePerDayByCategory"))
            } icon: {
                Image(systemName: "timer.square")
            }

            Chart(categoryEventDays, id:\.self) { day in
                BarMark(x: .value("X", day),
                        yStart: .value("Y", minDistancePerDay[day] ?? 0.0), yEnd: .value("Y", maxDistancePerDay[day] ?? 0.0))
            }
            .chartXScale(domain: allEventDays.first!...allEventDays.last!)
            .chartXAxis {
                AxisMarks(preset: .aligned) { value in
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day(.defaultDigits))
                }
            }
            .chartYScale(domain: 0.0...(maxDistance?.distance ?? 86400))
            .chartYAxis {
                AxisMarks(preset: .aligned) { value in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text((intValue / 3600).formatted())
                        }
                    }
                }
            }
            .frame(height: 100.0)
            .padding(.horizontal)
            
            HStack(alignment: .top) {
                VStack {
                        HStack(alignment: .bottom) {
                            Text(LocalizedStringKey("ReportViewMinDistancePerDayByCategory"))
                            Text(String(format: "%.1f", (minDistance?.distance ?? 0) / 3600) + " h")
                                .font(.body)
                                .foregroundColor(.primary)
                                .colorInvert()
                                .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                                .background(.green)
                                .cornerRadius(5)
                        }
                    Text((minDistance?.day ?? .now).formatted(date: .numeric, time: .omitted))
                }
                Spacer()
                VStack {
                        HStack(alignment: .bottom) {
                            Text(LocalizedStringKey("ReportViewMaxDistancePerDayByCategory"))
                            Text(String(format: "%.1f", (maxDistance?.distance ?? 86400) / 3600) + " h")
                                .font(.body)
                                .foregroundColor(.primary)
                                .colorInvert()
                                .padding(EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
                                .background(.red)
                                .cornerRadius(5)
                        }
                    Text((maxDistance?.day ?? .now).formatted(date: .numeric, time: .omitted))
                }
            }
            .multilineTextAlignment(.center)
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding()
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
            .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
            .environmentObject(CoreDataController.preview.settings)
    }
}
