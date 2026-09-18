//
//  GassiView.swift
//  Gassi
//
//  Created by Jan Löffel on 02.08.23.
//

import CoreData
import SwiftUI

struct GassiView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController
    
    var body: some View {
        NavigationStack(path: $navigationController.path) {
            VStack {
                RecentEventsListView()
                Spacer()
                DogStatusView(dog: GassiDog.current)
                AddGassiView()
                    .fixedSize()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    DogMenuView()
                }
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        predictionStatusImage
                    }
                    .sharedBackgroundVisibility(.hidden)
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        predictionStatusImage
                    }
                }
            }
            .navigationDestination(for: GassiEvent.self) { event in
                EventView(event: event)
            }
            .navigationTitle("GassiViewNavigationTitle")
        }
    }

    private var predictionStatusImage: some View {
        Image(systemName: navigationController.predictionStatus.symbolName)
            .foregroundStyle(navigationController.predictionStatus.color)
            .contentTransition(.symbolEffect(.replace))
            .allowsHitTesting(false)
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isImage)
            .help(navigationController.predictionStatus.message)
            .accessibilityLabel(navigationController.predictionStatus.message)
    }
}

private struct DogStatusView: View {
    @ObservedObject var dog: GassiDog
    @FetchRequest private var events: FetchedResults<GassiEvent>

    init(dog: GassiDog) {
        self.dog = dog
        _events = FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)],
            predicate: NSPredicate(format: "dog == %@ AND type.predict == TRUE", dog),
            animation: .default
        )
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let status = status(at: context.date)

            Label {
                Text(String(
                    format: localizedString(status.localizationKey, standardString: status.fallback),
                    dog.nameString
                ))
                .multilineTextAlignment(.leading)
            } icon: {
                Image(systemName: status.symbolName)
                    .foregroundStyle(status.color)
            }
            .font(.callout)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(status.color.opacity(0.12), in: .rect(cornerRadius: 14))
            .contentTransition(.opacity)
            .accessibilityElement(children: .combine)
        }
        .padding(.horizontal)
    }

    private func status(at date: Date) -> DogStatus {
        guard let lastEventDate = events.first?.timestamp else {
            return .noEvents
        }

        switch date.timeIntervalSince(lastEventDate) {
        case ..<(45 * 60):
            return .satisfied
        case ..<(2 * 60 * 60):
            return .happy
        case ..<(4 * 60 * 60):
            return .thinkingAboutWalk
        case ..<(6 * 60 * 60):
            return .walkRecommended
        default:
            return .underPressure
        }
    }
}

private enum DogStatus {
    case noEvents
    case satisfied
    case happy
    case thinkingAboutWalk
    case walkRecommended
    case underPressure

    var localizationKey: String {
        switch self {
        case .noEvents:
            return "DogStatusNoEvents"
        case .satisfied:
            return "DogStatusSatisfied"
        case .happy:
            return "DogStatusHappy"
        case .thinkingAboutWalk:
            return "DogStatusThinkingAboutWalk"
        case .walkRecommended:
            return "DogStatusWalkRecommended"
        case .underPressure:
            return "DogStatusUnderPressure"
        }
    }

    var fallback: String {
        switch self {
        case .noEvents:
            return "%@ is ready for the first adventure. 🐾"
        case .satisfied:
            return "%@ is completely satisfied—the last walk is still working its magic. 😌"
        case .happy:
            return "%@ is relaxed and happy. Everything is in the green zone! 🐶"
        case .thinkingAboutWalk:
            return "%@ is starting to think about another trip outside. 👀"
        case .walkRecommended:
            return "%@ says a walk would be a very good idea right now. 🦮"
        case .underPressure:
            return "Heads up: %@ is under serious pressure. Time for a walk! 🚨"
        }
    }

    var symbolName: String {
        switch self {
        case .noEvents:
            return "pawprint"
        case .satisfied:
            return "face.smiling"
        case .happy:
            return "heart.fill"
        case .thinkingAboutWalk:
            return "eye"
        case .walkRecommended:
            return "figure.walk"
        case .underPressure:
            return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .noEvents, .thinkingAboutWalk:
            return .blue
        case .satisfied, .happy:
            return .green
        case .walkRecommended:
            return .orange
        case .underPressure:
            return .red
        }
    }
}

struct GassiView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GassiView()
                .environmentObject(NavigationController())
                .environment(\.managedObjectContext, CoreDataController.preview.container.viewContext)
        }
    }
}
