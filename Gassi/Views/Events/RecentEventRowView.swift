//
//  RecentEventRowView.swift
//  Gassi
//
//  Created by Jan Löffel on 14.09.22.
//

import SwiftUI

struct RecentEventRowView: View {
    @EnvironmentObject var navigationController: NavigationController

    @ObservedObject var type: GassiType
    @State private var nextEventDate: Date?
    @State private var predictionFailureReason: GassiPredictionFailureReason?

    @FetchRequest private var events: FetchedResults<GassiEvent>

    init(type: GassiType) {
        self.type = type

        _events = FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)],
            predicate: NSPredicate(format: "type == %@", type),
            animation: .default
        )
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let lastEvent = events.first
            let now = context.date

            HStack {
                lastEventView(lastEvent, now: now)

                Spacer()
                typeSummaryView(for: lastEvent)
                Spacer()

                predictionView(now: now)
            }
        }
        .task(id: predictionTaskID) {
            await updatePrediction()
        }
    }

    @ViewBuilder
    private func lastEventView(_ event: GassiEvent?, now: Date) -> some View {
        if let event, let timestamp = event.timestamp {
            VStack(spacing: 4) {
                footnoteText(timestamp.relativeWeekday())

                lastEventElapsedBadge(since: timestamp, now: now)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))

                footnoteText(timestamp.formatted(date: .numeric, time: .shortened))
            }
            .background {
                NavigationLink(value: event) {
                    EmptyView()
                }
            }
        } else {
            Text("NoGassiEvent")
                .foregroundColor(.secondary)
        }
    }

    private func typeSummaryView(for lastEvent: GassiEvent?) -> some View {
        VStack {
            if let dogName = lastEvent?.dog?.name {
                Text(dogName)
                    .font(.footnote)
            }

            Text(type.sign ?? "")
                .font(.system(size: 48.0))

            Text(type.nameString)
                .font(.footnote)
        }
    }

    @ViewBuilder
    private func predictionView(now: Date) -> some View {
        if let nextEventDate {
            VStack(spacing: 4) {
                footnoteText(nextEventDate.relativeWeekday())

                nextEventBadge(distance: now.distance(to: nextEventDate))

                footnoteText(nextEventDate.formatted(date: .numeric, time: .shortened))
            }
        } else {
            Text(predictionFailureReason?.message ?? "NoPredictionPossible")
                .multilineTextAlignment(.trailing)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func lastEventElapsedBadge(since timestamp: Date, now: Date) -> some View {
        let elapsed = now.timeIntervalSince(timestamp)

        if elapsed < 60 {
            Text("justNow")
                .font(.title3)
                .lastEventBadgeStyle()
        } else {
            Text(TimeInterval.timeSpanString(elapsed, academic: true, showSeconds: false, offset: 0))
                .font(.system(.title3, design: .monospaced))
                .lastEventBadgeStyle()
        }
    }

    @ViewBuilder
    private func nextEventBadge(distance: TimeInterval) -> some View {
        if distance > (GassiEvent.gracePeriod * 2) {
            Text(TimeInterval.timeSpanString(distance, academic: true, showSeconds: false))
                .font(.system(.title3, design: .monospaced))
                .nextEventBadgeStyle(background: Color(uiColor: .systemFill))
        } else if distance > 60 {
            Text(TimeInterval.timeSpanString(distance, academic: true, showSeconds: false))
                .font(.system(.title3, design: .monospaced).bold())
                .nextEventBadgeStyle(background: Color("BadMood"))
                .shadow(color: Color.yellow, radius: 5.0, x: 0, y: 0)
        } else {
            Text("now")
                .textCase(.uppercase)
                .font(.title3.bold())
                .foregroundColor(.primary)
                .colorInvert()
                .padding(Self.badgeInsets)
                .background(.red)
                .cornerRadius(Self.badgeCornerRadius)
                .shadow(color: Color.orange, radius: 7.5, x: 0, y: 0)
        }
    }

    private func footnoteText(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundColor(.secondary)
    }

    private func updatePrediction() async {
        let refreshID = navigationController.nextPredictionRefreshID
        let sortedEvents = events.sorted { event1, event2 in
            event1.timestamp ?? .now > event2.timestamp ?? .now
        }
        let result = await GassiEvent.nextPrediction(
            events: sortedEvents,
            eventDays: GassiEvent.daysCount(events: sortedEvents)
        )

        guard !Task.isCancelled else { return }

        switch result {
        case .success(let predictedDate):
            nextEventDate = predictedDate
            predictionFailureReason = nil
        case .failure(let reason):
            nextEventDate = nil
            predictionFailureReason = reason
        }

        navigationController.registerPredictionResult(for: refreshID, result: result)
    }

    private var predictionTaskID: String {
        let eventsID = events.compactMap(\.timestamp)
            .sorted()
            .map { String(Int($0.timeIntervalSinceReferenceDate)) }
            .joined(separator: "|")

        return "\(eventsID)-\(navigationController.nextPredictionRefreshID.uuidString)"
    }

    fileprivate static let badgeInsets = EdgeInsets(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)
    fileprivate static let badgeCornerRadius = 5.0
}

private extension Text {
    func lastEventBadgeStyle() -> some View {
        foregroundColor(.primary)
            .colorInvert()
            .padding(RecentEventRowView.badgeInsets)
            .background(Color.accentColor)
            .cornerRadius(RecentEventRowView.badgeCornerRadius)
    }

    func nextEventBadgeStyle(background: Color) -> some View {
        foregroundColor(.primary)
            .padding(RecentEventRowView.badgeInsets)
            .background(background)
            .cornerRadius(RecentEventRowView.badgeCornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: RecentEventRowView.badgeCornerRadius)
                    .stroke(lineWidth: 1.0)
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
