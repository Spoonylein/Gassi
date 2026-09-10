//
//  CoreDataExtensions.swift
//  Gassi
//
//  Created by Jan Löffel on 23.07.23.
//

import Foundation
import CoreData
import SwiftUI
#if canImport(FoundationModels)
import FoundationModels
#endif

extension Notification.Name {
    static let gassiEventDidCreate = Notification.Name("gassiEventDidCreate")
}

enum GassiPredictionFailureReason: Equatable {
    case notEnoughHistory
    case foundationModelsUnavailable
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    case unsupportedLocale
    case refusal
    case lowConfidence
    case invalidDate
    case predictedDateInPast
    case predictedDateTooFar
    case decodingFailure
    case guardrailViolation
    case rateLimited
    case assetsUnavailable
    case exceededContextWindow
    case concurrentRequests
    case unsupportedGuide
    case other(String)

    var message: String {
        switch self {
        case .notEnoughHistory:
            return localizedString("PredictionNotEnoughHistory", standardString: "Mindestens 3 Ereignisse erforderlich")
        case .foundationModelsUnavailable:
            return localizedString("PredictionFoundationModelsUnavailable", standardString: "Mathematische Prognose wird verwendet")
        case .deviceNotEligible:
            return localizedString("PredictionDeviceNotEligible", standardString: "Apple Intelligence wird auf diesem Gerät nicht unterstützt")
        case .appleIntelligenceNotEnabled:
            return localizedString("PredictionAppleIntelligenceNotEnabled", standardString: "Apple Intelligence ist deaktiviert")
        case .modelNotReady:
            return localizedString("PredictionModelNotReady", standardString: "Apple Intelligence ist noch nicht bereit")
        case .unsupportedLocale:
            return localizedString("PredictionUnsupportedLocale", standardString: "Aktuelle Sprache wird nicht unterstützt")
        case .refusal:
            return localizedString("PredictionRefusal", standardString: "Modell hat die Prognose abgelehnt")
        case .lowConfidence:
            return localizedString("PredictionLowConfidence", standardString: "Zu wenig Daten")
        case .invalidDate:
            return localizedString("PredictionInvalidDate", standardString: "Modell hat ein ungültiges Datum geliefert")
        case .predictedDateInPast:
            return localizedString("PredictionDateInPast", standardString: "Prognose liegt nicht nach dem letzten Ereignis")
        case .predictedDateTooFar:
            return localizedString("PredictionDateTooFar", standardString: "Prognose liegt zu weit in der Zukunft")
        case .decodingFailure:
            return localizedString("PredictionDecodingFailure", standardString: "Modellausgabe konnte nicht gelesen werden")
        case .guardrailViolation:
            return localizedString("PredictionGuardrailViolation", standardString: "Modellausgabe wurde blockiert")
        case .rateLimited:
            return localizedString("PredictionRateLimited", standardString: "Modell ist vorübergehend limitiert")
        case .assetsUnavailable:
            return localizedString("PredictionAssetsUnavailable", standardString: "Modelldaten sind nicht verfügbar")
        case .exceededContextWindow:
            return localizedString("PredictionExceededContextWindow", standardString: "Historie ist zu lang")
        case .concurrentRequests:
            return localizedString("PredictionConcurrentRequests", standardString: "Prognose läuft bereits")
        case .unsupportedGuide:
            return localizedString("PredictionUnsupportedGuide", standardString: "Prognoseschema wird nicht unterstützt")
        case .other(let message):
            return message
        }
    }
}

enum GassiPredictionResult: Equatable {
    case success(Date)
    case failure(GassiPredictionFailureReason)
}

private struct GassiPredictionFeedback: Codable, Sendable {
    let id: UUID
    let categoryID: UUID
    let dogID: UUID?
    let issuedAt: Date
    let aiDate: Date
    let scheduleDate: Date?
    let selectedDate: Date
    var actualEventID: UUID?
    var actualDate: Date?
    var aiError: TimeInterval?
    var scheduleError: TimeInterval?
}

private enum GassiPredictionFeedbackStore {
    private static let defaultsKey = "GassiPredictionFeedback"
    private static let maximumEntries = 100
    private static let minimumSamplesForAdaptation = 3
    private static let minimumError: TimeInterval = 5 * 60
    private static let queue = DispatchQueue(label: "GassiPredictionFeedbackStore")

    static func recordPrediction(
        categoryID: UUID,
        dogID: UUID?,
        aiDate: Date,
        scheduleDate: Date?,
        selectedDate: Date
    ) {
        queue.sync {
            var feedback = load()
            feedback.append(
                GassiPredictionFeedback(
                    id: UUID(),
                    categoryID: categoryID,
                    dogID: dogID,
                    issuedAt: .now,
                    aiDate: aiDate,
                    scheduleDate: scheduleDate,
                    selectedDate: selectedDate
                )
            )
            save(Array(feedback.suffix(maximumEntries)))
        }
    }

    static func recordActualEvent(categoryID: UUID, dogID: UUID?, eventID: UUID, actualDate: Date) {
        queue.sync {
            var feedback = load()
            var didChange = false

            feedback.removeAll { item in
                guard item.actualEventID == eventID else { return false }
                let eventStillMatchesPrediction = item.categoryID == categoryID
                    && item.dogID == dogID
                    && item.issuedAt <= actualDate
                didChange = didChange || !eventStillMatchesPrediction
                return !eventStillMatchesPrediction
            }

            let matchingResolvedIndices = feedback.indices.filter { feedback[$0].actualEventID == eventID }
            for index in matchingResolvedIndices {
                updateResolvedFeedback(&feedback[index], actualDate: actualDate)
                didChange = true
            }

            if matchingResolvedIndices.isEmpty,
               let index = feedback.indices.reversed().first(where: {
                   feedback[$0].categoryID == categoryID
                       && feedback[$0].dogID == dogID
                       && feedback[$0].actualDate == nil
                       && feedback[$0].issuedAt <= actualDate
               }) {
                feedback[index].actualEventID = eventID
                updateResolvedFeedback(&feedback[index], actualDate: actualDate)
                didChange = true
            }

            if didChange {
                save(feedback)
            }
        }
    }

    static func invalidateActualEvent(eventID: UUID) {
        queue.sync {
            let feedback = load().filter { $0.actualEventID != eventID }
            save(feedback)
        }
    }

    static func invalidateDog(dogID: UUID) {
        queue.sync {
            let feedback = load().filter { $0.dogID != dogID }
            save(feedback)
        }
    }

    static func invalidateCategory(categoryID: UUID) {
        queue.sync {
            let feedback = load().filter { $0.categoryID != categoryID }
            save(feedback)
        }
    }

    private static func updateResolvedFeedback(_ feedback: inout GassiPredictionFeedback, actualDate: Date) {
        feedback.actualDate = actualDate
        feedback.aiError = abs(actualDate.timeIntervalSince(feedback.aiDate))

        if let scheduleDate = feedback.scheduleDate {
            feedback.scheduleError = abs(actualDate.timeIntervalSince(scheduleDate))
        } else {
            feedback.scheduleError = nil
        }
    }

    static func weights(categoryID: UUID, dogID: UUID?) -> (ai: Double, schedule: Double) {
        queue.sync {
            let resolved = load()
                .filter { $0.categoryID == categoryID && $0.dogID == dogID && $0.actualDate != nil }
                .suffix(20)

            let aiErrors = resolved.compactMap(\.aiError)
            let scheduleErrors = resolved.compactMap(\.scheduleError)

            guard aiErrors.count >= minimumSamplesForAdaptation,
                  scheduleErrors.count >= minimumSamplesForAdaptation else {
                return (0.5, 0.5)
            }

            let aiMeanError = aiErrors.reduce(0, +) / Double(aiErrors.count)
            let scheduleMeanError = scheduleErrors.reduce(0, +) / Double(scheduleErrors.count)
            let aiScore = 1 / max(aiMeanError, minimumError)
            let scheduleScore = 1 / max(scheduleMeanError, minimumError)
            let scoreTotal = aiScore + scheduleScore

            return (aiScore / scoreTotal, scheduleScore / scoreTotal)
        }
    }

    private static func load() -> [GassiPredictionFeedback] {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let feedback = try? JSONDecoder().decode([GassiPredictionFeedback].self, from: data) else {
            return []
        }

        return feedback
    }

    private static func save(_ feedback: [GassiPredictionFeedback]) {
        guard let data = try? JSONEncoder().encode(feedback) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }
}

private enum GassiSchedulePredictor {
    static let minimumPredictionLeadTime: TimeInterval = 15 * 60
    static let maximumPredictionHorizon: TimeInterval = 36 * 60 * 60
    static let maximumScheduleDeviation: TimeInterval = 2 * 60 * 60

    static func prediction(eventDates: [Date], timeZone: TimeZone = .autoupdatingCurrent) -> GassiPredictionResult {
        guard eventDates.count >= 3 else { return .failure(.notEnoughHistory) }
        guard let scheduleDate = scheduleBasedDate(eventDates: eventDates, timeZone: timeZone) else {
            return .failure(.lowConfidence)
        }

        return .success(max(scheduleDate, Date.now))
    }

    static func scheduleBasedDate(eventDates: [Date], timeZone: TimeZone) -> Date? {
        guard let lastEvent = eventDates.max() else { return nil }

        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = timeZone

        let recentCutoff = lastEvent.addingTimeInterval(-14 * 24 * 60 * 60)
        let minutesOfDay = eventDates
            .filter { $0 >= recentCutoff }
            .map {
                let components = calendar.dateComponents([.hour, .minute], from: $0)
                return (components.hour ?? 0) * 60 + (components.minute ?? 0)
            }
            .sorted()

        guard minutesOfDay.count >= 3 else { return nil }

        var clusters: [[Int]] = []
        for minute in minutesOfDay {
            if let lastCluster = clusters.last,
               minute - median(lastCluster) <= 120 {
                clusters[clusters.count - 1].append(minute)
            } else {
                clusters.append([minute])
            }
        }

        let recurringMinutes = clusters
            .filter { $0.count >= 2 }
            .map(median)
            .sorted()

        guard !recurringMinutes.isEmpty else { return nil }

        let earliestPrediction = lastEvent.addingTimeInterval(minimumPredictionLeadTime)
        let referenceDay = calendar.startOfDay(for: lastEvent)

        for dayOffset in 0 ... 2 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: referenceDay) else {
                continue
            }

            for minute in recurringMinutes {
                if let candidate = calendar.date(byAdding: .minute, value: minute, to: day),
                   candidate > earliestPrediction {
                    return candidate
                }
            }
        }

        return nil
    }

    private static func median(_ values: [Int]) -> Int {
        let sortedValues = values.sorted()
        let middle = sortedValues.count / 2

        if sortedValues.count.isMultiple(of: 2) {
            return (sortedValues[middle - 1] + sortedValues[middle]) / 2
        }

        return sortedValues[middle]
    }
}

#if canImport(FoundationModels)
@available(iOS 26.0, macOS 26.0, watchOS 26.0, *)
@Generable(description: "A prediction for the next dog relief event.")
private struct GassiNextEventPrediction {
    var predictionPossible: Bool

    @Guide(description: "Confidence score for the prediction.", .range(0.0 ... 1.0))
    var confidence: Double

    @Guide(description: "Four digit year of the predicted local date.", .range(2024 ... 2100))
    var year: Int

    @Guide(description: "Month of year.", .range(1 ... 12))
    var month: Int

    @Guide(description: "Day of month.", .range(1 ... 31))
    var day: Int

    @Guide(description: "Hour in 24 hour time.", .range(0 ... 23))
    var hour: Int

    @Guide(description: "Minute of hour.", .range(0 ... 59))
    var minute: Int
}

@available(iOS 26.0, macOS 26.0, watchOS 26.0, *)
private enum GassiAIPredictor {
    private static func localPredictionTimestampString(for date: Date, timeZone: TimeZone) -> String {
        var calendar = Calendar.current
        calendar.timeZone = timeZone

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.autoupdatingCurrent
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"

        return formatter.string(from: date)
    }

    private static func validatedPredictionDate(
        _ predictedDate: Date,
        eventDates: [Date],
        timeZone: TimeZone,
        categoryID: UUID?,
        dogID: UUID?
    ) -> GassiPredictionResult {
        guard let lastEvent = eventDates.max() else { return .failure(.notEnoughHistory) }

        let referenceDate = max(Date.now, lastEvent)
        let earliestPrediction = referenceDate.addingTimeInterval(GassiSchedulePredictor.minimumPredictionLeadTime)
        let latestPrediction = referenceDate.addingTimeInterval(GassiSchedulePredictor.maximumPredictionHorizon)
        let scheduleDate = GassiSchedulePredictor.scheduleBasedDate(eventDates: eventDates, timeZone: timeZone)
        let actionableScheduleDate = scheduleDate.map { max($0, Date.now) }

        let selectedDate: Date

        if predictedDate <= earliestPrediction || predictedDate > latestPrediction {
            guard let actionableScheduleDate else {
                return predictedDate <= earliestPrediction
                    ? .failure(.predictedDateInPast)
                    : .failure(.predictedDateTooFar)
            }
            selectedDate = actionableScheduleDate
        } else if let scheduleDate, let actionableScheduleDate {
            if abs(predictedDate.timeIntervalSince(scheduleDate)) > GassiSchedulePredictor.maximumScheduleDeviation {
                selectedDate = actionableScheduleDate
            } else if let categoryID {
                let weights = GassiPredictionFeedbackStore.weights(categoryID: categoryID, dogID: dogID)
                let blendedTimestamp =
                    predictedDate.timeIntervalSinceReferenceDate * weights.ai
                    + actionableScheduleDate.timeIntervalSinceReferenceDate * weights.schedule
                selectedDate = Date(timeIntervalSinceReferenceDate: blendedTimestamp)
            } else {
                selectedDate = predictedDate
            }
        } else {
            selectedDate = predictedDate
        }

        if let categoryID {
            GassiPredictionFeedbackStore.recordPrediction(
                categoryID: categoryID,
                dogID: dogID,
                aiDate: predictedDate,
                scheduleDate: scheduleDate,
                selectedDate: selectedDate
            )
        }

        return .success(selectedDate)
    }

    static func nextDate(eventDates: [Date], categoryID: UUID?, dogID: UUID?) async -> GassiPredictionResult {
        guard eventDates.count >= 3 else { return .failure(.notEnoughHistory) }
        
        switch SystemLanguageModel.default.availability {
        case .available:
            break
        case .unavailable(.deviceNotEligible):
            return .failure(.deviceNotEligible)
        case .unavailable(.appleIntelligenceNotEnabled):
            return .failure(.appleIntelligenceNotEnabled)
        case .unavailable(.modelNotReady):
            return .failure(.modelNotReady)
        case .unavailable(let reason):
            return .failure(.other(String(describing: reason)))
        }
        
        guard SystemLanguageModel.default.supportsLocale() else {
            return .failure(.unsupportedLocale)
        }
        
        let timeZone = TimeZone.autoupdatingCurrent
        let calendar = Calendar.autoupdatingCurrent
        let history = eventDates.sorted()
            .map { localPredictionTimestampString(for: $0, timeZone: timeZone) }
            .joined(separator: "\n")
        let prompt = """
        Predict the next likely date and time for a dog's relief event from historical observations.
        Return the single most likely next event after the last observed event.
        Prefer recurring spacing and time-of-day patterns over broad guesses.
        If the history is too weak or inconsistent, set predictionPossible to false.

        Historical events in ascending order:
        \(history)
        """

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(
                to: prompt,
                generating: GassiNextEventPrediction.self,
                options: GenerationOptions(temperature: 0.1)
            )
            let prediction = response.content

            guard prediction.predictionPossible, prediction.confidence >= 0.35 else {
                return .failure(.lowConfidence)
            }

            var components = DateComponents()
            components.calendar = calendar
            components.timeZone = timeZone
            components.year = prediction.year
            components.month = prediction.month
            components.day = prediction.day
            components.hour = prediction.hour
            components.minute = prediction.minute

            guard let predictedDate = calendar.date(from: components) else {
                return .failure(.invalidDate)
            }

            return validatedPredictionDate(
                predictedDate,
                eventDates: eventDates,
                timeZone: timeZone,
                categoryID: categoryID,
                dogID: dogID
            )
        } catch LanguageModelSession.GenerationError.unsupportedLanguageOrLocale {
            return .failure(.unsupportedLocale)
        } catch LanguageModelSession.GenerationError.refusal {
            return .failure(.refusal)
        } catch LanguageModelSession.GenerationError.decodingFailure {
            return .failure(.decodingFailure)
        } catch LanguageModelSession.GenerationError.guardrailViolation {
            return .failure(.guardrailViolation)
        } catch LanguageModelSession.GenerationError.rateLimited {
            return .failure(.rateLimited)
        } catch LanguageModelSession.GenerationError.assetsUnavailable {
            return .failure(.assetsUnavailable)
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            return .failure(.exceededContextWindow)
        } catch LanguageModelSession.GenerationError.concurrentRequests {
            return .failure(.concurrentRequests)
        } catch LanguageModelSession.GenerationError.unsupportedGuide {
            return .failure(.unsupportedGuide)
        } catch {
            return .failure(.other(error.localizedDescription))
        }
    }
}
#endif

/// Enum of ID strings for default Gassi core data objects
//enum GassiIDStrings: String {
//    case peeType = "07031973-1000-6000-1000-000000001000"
//    case pooType = "07031973-1000-6000-1100-000000002000"
//}

extension GassiDog {

    private static var _current: GassiDog? = nil
    static var current: GassiDog {
        get {
            if _current == nil {
                return GassiDog()
            } else {
                return _current!
            }
        }
        set {
            if _current != newValue {
                let oldCurrentDog = _current
                _current = newValue
                
                if let newDog = _current {
                    newDog.managedObjectContext?.refresh(newDog, mergeChanges: true)
                }
                if let oldDog = oldCurrentDog {
                    oldDog.managedObjectContext?.refresh(oldDog, mergeChanges: true)
                }
                
                UserDefaults.standard.set(_current?.id?.uuidString, forKey: UserDefaultsKeys.currentDogIDString.rawValue)
                print("currentDogID \(_current?.id?.uuidString ?? "nil") saved in UserDefaults.")
            }
        }
    }
        
    static func new(context: NSManagedObjectContext, id: UUID = UUID(), name: String = localizedString("NewDog"), breed: GassiBreed? = nil, birthday: Date? = nil, sex: GassiSex? = nil, events: NSSet? = nil) -> GassiDog {
        let dog = GassiDog(context: context)
        
        dog.id = id
        dog.name = name
        dog.breed = breed
        dog.birthday = birthday
        dog.sex = sex
        if let _events = events { dog.addToEvents(_events) }
        
        return dog
    }
    
    var nameString: String {
        var result = localizedString("NamelessDog")
        
        if let name = self.name {
            result = name
        }
        
        return result
    }
    
    var breedNameString: String {
        var result = ""
        
        if let breed = self.breed {
            result = breed.nameString
        }
        
        return result
    }
    
    var sexNameString: String {
        var result = ""

        if let sex = self.sex {
            result = sex.nameString
        }
        
        return result
    }
    
    var ageString: String {
        var result = ""
        
        if let birthday = self.birthday, let years = Calendar.current.dateComponents([.year], from: birthday, to: .now).year {
            if years == 1 {
                result = "\(years)"
            } else {
                result = "\(years)"
            }
        }
        
        return result
    }
    
    var isCurrent: Bool {
        return GassiDog.current == self
    }
    
    func makeCurrent() {
        GassiDog.current = self
    }
}

extension GassiBreed: Encodable {
    enum CodingKeys: CodingKey {
        case name
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
    }
    
    static func new(context: NSManagedObjectContext, id: UUID = UUID(), name: String = localizedString("NewBreed"), dogs: NSSet? = nil) -> GassiBreed {
        let breed = GassiBreed(context: context)

        breed.id = id
        breed.name = name
        if let _dogs = dogs { breed.addToDogs(_dogs) }
        
        return breed
    }
    
    var nameString: String {
        var result = localizedString("NamelessBreed")
        
        if let name = self.name {
            result = name
        }
        
        return result
    }

}

extension GassiSex {
    static func new(context: NSManagedObjectContext, id: UUID = UUID(), name: String = localizedString("NewSex"), dogs: NSSet? = nil) -> GassiSex {
        let sex = GassiSex(context: context)

        sex.id = id
        sex.name = name
        if let _dogs = dogs { sex.addToDogs(_dogs) }
        
        return sex
    }
    
    var nameString: String {
        var result = ""
        
        if let name = self.name {
            result = name
        }
        
        return result
    }
}

extension GassiType {
    static let peeID: UUID = UUID(uuidString: "07031973-1000-6000-1000-000000001000")!
    static let pooID: UUID = UUID(uuidString: "07031973-1000-6000-1100-000000002000")!

    static func new(context: NSManagedObjectContext, id: UUID = UUID(), name: String = localizedString("NewType"), sign: String = localizedString("TypeSign"), predict: Bool = false, subtypes: NSSet? = nil, events: NSSet? = nil) -> GassiType {
        let type = GassiType(context: context)
        
        type.id = id
        type.name = name
        type.sign = sign
        type.predict = predict
        if let _subtypes = subtypes { type.addToSubtypes(_subtypes) }
        if let _events = events { type.addToEvents(_events) }
        
        return type
    }
    
    static func newPoo(context: NSManagedObjectContext) -> GassiType {
        return new(context: context, id: GassiType.pooID, name: "Poo", sign: "💩", predict: true)
    }
    
    static func newPee(context: NSManagedObjectContext) -> GassiType {
        return new(context: context, id: GassiType.peeID, name: "Pee", sign: "💦", predict: true)
    }
    
    private static var _poo: GassiType? = nil
    static var poo: GassiType {
        get {
            if _poo == nil {
                return GassiType()
            } else {
                return _poo!
            }
        }
        set {
            if _poo != newValue {
                _poo = newValue
            }
        }
    }

    private static var _pee: GassiType? = nil
    static var pee: GassiType {
        get {
            if _pee == nil {
                return GassiType()
            } else {
                return _pee!
            }
        }
        set {
            if _pee != newValue {
                _pee = newValue
            }
        }
    }

    var nameString: String {
        var result = ""
        
        if let name = self.name {
            result = name
        }
        
        return result
    }
    
    var isPeeOrPoo: Bool {
        return self == GassiType.pee || self == GassiType.poo
    }

}

extension GassiSubtype {
    static let hardPooID: UUID = UUID(uuidString: "07031973-1000-6000-1100-000000002100")!
    static let diarrheaPooID: UUID = UUID(uuidString: "07031973-1000-6000-1100-000000002200")!

    static func new(context: NSManagedObjectContext, id: UUID = UUID(), name: String = "new subtype", sign: String? = nil, type: GassiType, events: NSSet? = nil) -> GassiSubtype {
        let subtype = GassiSubtype(context: context)
        
        subtype.id = id
        subtype.name = name
        subtype.sign = sign
        subtype.type = type
        if let _events = events { subtype.addToEvents(_events) }
        
        return subtype
    }
    
    static func newHardPoo(context: NSManagedObjectContext) -> GassiSubtype {
        return new(context: context, id: hardPooID, name: localizedString("HardPoo"), sign: localizedString("HardPooSign"), type: GassiType.poo)
    }
    
    static func newDiarrheaPoo(context: NSManagedObjectContext) -> GassiSubtype {
        return new(context: context, id: diarrheaPooID, name: localizedString("Diarrhea"), sign: localizedString("DiarrheaSign"), type: GassiType.poo)
    }
        
    var nameString: String {
        var result = ""
        
        if let name = self.name {
            result = name
        }
        
        return result
    }

}

extension GassiEvent {
    static let defaultGracePeriod: TimeInterval = 15 * 60
    static let defaultTimespan: TimeInterval = 30 * 24 * 60 * 60

    private static var _gracePeriod: TimeInterval = defaultGracePeriod
    static var gracePeriod: TimeInterval {
        get {
            return _gracePeriod
        }
        set {
            if _gracePeriod != newValue {
                _gracePeriod = newValue
                
                UserDefaults.standard.set(_gracePeriod, forKey: UserDefaultsKeys.eventsGracePeriod.rawValue)
                print("eventsGracePeriod \(_gracePeriod) saved in UserDefaults.")
            }
        }
    }

    private static var _timespan: TimeInterval = defaultTimespan
    static var timespan: TimeInterval {
        get {
            return _timespan
        }
        set {
            if _timespan != newValue {
                _timespan = newValue
                
                UserDefaults.standard.set(_timespan, forKey: UserDefaultsKeys.eventsTimespan.rawValue)
                print("eventsTimespan \(_timespan) saved in UserDefaults.")
            }
        }
    }

    static func new(context: NSManagedObjectContext, timestamp: Date = Date.now, dog: GassiDog, type: GassiType, subtype: GassiSubtype? = nil) -> GassiEvent {
        // Check for an existing event within grace period and use it instead of creating a new event.
        let fetchRequest: NSFetchRequest = GassiEvent.fetchRequest()
        let lowerTimestamp = timestamp.addingTimeInterval(-gracePeriod)
        let upperTimestamp = timestamp.addingTimeInterval(gracePeriod)
        let timestampPredicate = NSPredicate(
            format: "timestamp >= %@ AND timestamp <= %@",
            lowerTimestamp as CVarArg,
            upperTimestamp as CVarArg
        )
        let dogPredicate = NSPredicate(format: "dog == %@", dog)
        let typePredicate = NSPredicate(format: "type == %@", type)
        let subtypePredicate = subtype != nil ? NSPredicate(format: "subtype == %@", subtype!) : NSPredicate(format: "subtype == NIL")
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [timestampPredicate, dogPredicate, typePredicate, subtypePredicate])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        if let gracePeriodEvent = try? context.fetch(fetchRequest).min(by: {
            abs(($0.timestamp ?? timestamp).timeIntervalSince(timestamp)) < abs(($1.timestamp ?? timestamp).timeIntervalSince(timestamp))
        }) {
            gracePeriodEvent.timestamp = timestamp
            if let categoryID = type.id, let eventID = gracePeriodEvent.id {
                GassiPredictionFeedbackStore.recordActualEvent(
                    categoryID: categoryID,
                    dogID: dog.id,
                    eventID: eventID,
                    actualDate: timestamp
                )
            }
            return gracePeriodEvent
        }
        
        let event = GassiEvent(context: context)
        event.id = UUID()
        event.timestamp = timestamp
        event.dog = dog
        event.type = type
        event.subtype = subtype

        if let categoryID = type.id, let eventID = event.id {
            GassiPredictionFeedbackStore.recordActualEvent(
                categoryID: categoryID,
                dogID: dog.id,
                eventID: eventID,
                actualDate: timestamp
            )
        }
        
        groom(in: context)
        NotificationCenter.default.post(name: .gassiEventDidCreate, object: event)
        
        return event
    }
    
    static func groom(in viewContext: NSManagedObjectContext, to timespan: TimeInterval = GassiEvent.timespan) {
        // Delete all events older than `days`
        let fetchRequest: NSFetchRequest = GassiEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp < %@", Date.now.addingTimeInterval(-timespan) as CVarArg)
        
        if let events = try? viewContext.fetch(fetchRequest) {
            events.forEach(viewContext.delete)
        }
    }

    static func reconcilePredictionFeedback(for notification: Notification) {
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            deletedObjects.forEach(invalidatePredictionFeedback)
        }

        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            updatedObjects.forEach(reevaluatePredictionFeedback)
        }
    }

    private static func invalidatePredictionFeedback(for object: NSManagedObject) {
        if let event = object as? GassiEvent, let eventID = event.id {
            GassiPredictionFeedbackStore.invalidateActualEvent(eventID: eventID)
        } else if let dog = object as? GassiDog, let dogID = dog.id {
            GassiPredictionFeedbackStore.invalidateDog(dogID: dogID)
        } else if let type = object as? GassiType, let categoryID = type.id {
            GassiPredictionFeedbackStore.invalidateCategory(categoryID: categoryID)
        }
    }

    private static func reevaluatePredictionFeedback(for object: NSManagedObject) {
        guard let event = object as? GassiEvent,
              let eventID = event.id else {
            return
        }

        guard let categoryID = event.type?.id,
              let actualDate = event.timestamp else {
            GassiPredictionFeedbackStore.invalidateActualEvent(eventID: eventID)
            return
        }

        GassiPredictionFeedbackStore.recordActualEvent(
            categoryID: categoryID,
            dogID: event.dog?.id,
            eventID: eventID,
            actualDate: actualDate
        )
    }
    
    static func eventDays(events: [GassiEvent]) -> [Date] {
        var result: [Date] = []
        
        for event in events {
            let day = Calendar.current.startOfDay(for: event.timestamp ?? .now)
            if !result.contains(day) { result.append(day) }
        }
        
        return result
    }
    
    static func daysCount(events: FetchedResults<GassiEvent>) -> Int {
        return eventDays(events: events.sorted(by: { event1, event2 in
            return event1.timestamp ?? .now < event2.timestamp ?? .now
        })).count
    }
    
    static func daysCount(events: [GassiEvent]) -> Int {
        var result: Int = 0
        
        var eventDays: [Date] = [Date]()    // Unique array of days with events
        for event in events {
            let day = Calendar.current.startOfDay(for: event.timestamp ?? .now)
            if !eventDays.contains(day) { eventDays.append(day) }
        }
        result = eventDays.count
        
        return result
    }
    
    static func distancesSum(descendingSortedEvents: [GassiEvent]) -> TimeInterval {
        var result: TimeInterval = 0
        
        for (index, event) in descendingSortedEvents.enumerated() {
            if index < descendingSortedEvents.count - 1 {
                result += (descendingSortedEvents[index + 1].timestamp ?? .now).distance(to: event.timestamp ?? .now)
            }
        }
        
        print(result.formatted())
        return result
    }
    
    static func distancesSum(fetchedDescendingSortedEvents: FetchedResults<GassiEvent>) -> TimeInterval {
        var result: TimeInterval = 0

        for (index, event) in fetchedDescendingSortedEvents.enumerated() {
            if index > 0 {
                result += (event.timestamp ?? .now).distance(to: fetchedDescendingSortedEvents[index - 1].timestamp ?? .now)
            }
        }

        print(result.formatted())
        return result
    }
    
    static func eventsPerDayCount(events: [GassiEvent]) -> [Date:Int] {
        var result: [Date:Int] = [:]
        
        for event in events {
            let day = Calendar.current.startOfDay(for: event.timestamp ?? .now)
            if !Calendar.current.isDateInToday(day) {
                if let count = result[day] {
                    result[day] = count + 1
                } else {
                    result[day] = 1
                }
            }
        }
        
        return result
    }
    
    static func minEventsCount(events: [GassiEvent]) -> (day: Date, eventCount: Int) {
        var minCount: Int = 0
        var minDate: Date = .now
        let epdc = eventsPerDayCount(events: events)
        
        for (index, day) in epdc.keys.enumerated() {
            if let count = epdc[day] {
                if index == 0 || count <= minCount {
                    minCount = count
                    minDate = day
                }
            }
        }
        
        return (minDate, minCount)
    }
    
    static func maxEventsCount(events: [GassiEvent]) -> (day: Date, eventCount: Int) {
        var maxCount: Int = 0
        var maxDate: Date = .now
        let epdc = eventsPerDayCount(events: events)
        
        for (index, day) in epdc.keys.enumerated() {
            if let count = epdc[day] {
                if index == 0 || count >= maxCount {
                    maxCount = count
                    maxDate = day
                }
            }
        }
        
        return (maxDate, maxCount)
    }
    
    static func minDistancePerDay(events: [GassiEvent]) -> [Date:TimeInterval] {
        var result: [Date:TimeInterval] = [:]
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp ?? .now > event2.timestamp ?? .now
        })
        for (index,event) in dscSortedEvents.enumerated() {
            if index > 0 {
                let day = Calendar.current.startOfDay(for: event.timestamp ?? .now)
                if let previousEvent = event.previous(events: dscSortedEvents, dog: event.dog, category: event.type), !Calendar.current.isDateInToday(day) {
                    if let distance = result[day] {
                        result[day] = min(distance, (previousEvent.timestamp ?? .now).distance(to: event.timestamp ?? .now))
                    } else {
                        result[day] = (previousEvent.timestamp ?? .now).distance(to: event.timestamp ?? .now)
                    }
                }

            }
        }
        
        return result
    }

    static func maxDistancePerDay(events: [GassiEvent]) -> [Date:TimeInterval] {
        var result: [Date:TimeInterval] = [:]
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp ?? .now > event2.timestamp ?? .now
        })

        for (index,event) in dscSortedEvents.enumerated() {
            if index > 0 {
                let day = Calendar.current.startOfDay(for: event.timestamp ?? .now)
                if let previousEvent = event.previous(events: dscSortedEvents, dog: event.dog, category: event.type), !Calendar.current.isDateInToday(day) {
                    if let distance = result[day] {
                        result[day] = max(distance, (previousEvent.timestamp ?? .now).distance(to: event.timestamp ?? .now))
                    } else {
                        result[day] = (previousEvent.timestamp ?? .now).distance(to: event.timestamp ?? .now)
                    }
                }
            }
        }
        
        return result
    }

    static func minDistance(events: [GassiEvent]) -> (day: Date, distance: TimeInterval)? {
        let minDistances = minDistancePerDay(events: events)
        if let minimum = minDistances.min(by: { a, b in
            return a.value < b.value
        }) {
            return (minimum.key, minimum.value)
        } else {
            return nil
        }
    }
    
    static func maxDistance(events: [GassiEvent]) -> (day: Date, distance: TimeInterval)? {
        let maxDistances = maxDistancePerDay(events: events)
        if let maximum = maxDistances.min(by: { a, b in
            return a.value > b.value
        }) {
            return (maximum.key, maximum.value)
        } else {
            return nil
        }
    }
    
    static func next(viewContext: NSManagedObjectContext, dog: GassiDog? = nil, intervals: Int = 6, minProbability: Double = 0.15) async -> GassiEvent? {
        var result: GassiEvent? = nil
        
        let eventsFetchRequest = GassiEvent.fetchRequest()
        let eventsSortDescriptor = NSSortDescriptor(key: "cd_timestamp", ascending: false)
        eventsFetchRequest.sortDescriptors = [eventsSortDescriptor]
        
        let categoriesFetchRequest = GassiType.fetchRequest()
        let categoriesSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        categoriesFetchRequest.sortDescriptors = [categoriesSortDescriptor]
        
        // Save all gassi events of given dog in `allGassiEvents`, save all default gassi categories in allGassiDefaultCategories.
        if let allGassiEvents = try? viewContext.fetch(eventsFetchRequest).filter({ item in
            guard let dog else { return true }
            return item.dog == dog
        }), let allGassiDefaultCategories = try? viewContext.fetch(categoriesFetchRequest).filter({ item in
            return item.predict
        }) {
            
            // Iterate over all default categories
            for category in allGassiDefaultCategories {
                let categoryGassiEvents = allGassiEvents.filter { item in
                    return item.type == category
                }
                
                if case .success(let nextGassiDate) = await nextPrediction(events: categoryGassiEvents,
                                                                           intervals: intervals,
                                                                           eventDays: daysCount(events: allGassiEvents),
                                                                           minProbability: minProbability) {
                    if let nextEvent = result {
                        if nextGassiDate < nextEvent.timestamp ?? .now {
                            result = GassiEvent()
                            result?.dog = dog
                            result?.type = category
                            result?.timestamp = nextGassiDate
                        }
                    } else {
                        result = GassiEvent()
                        result?.dog = dog
                        result?.type = category
                        result?.timestamp = nextGassiDate
                    }
                }
            }
        }
        
        return result
    }
    
    static func nextPrediction(events: [GassiEvent], intervals: Int = 6, eventDays: Int, minProbability: Double = 0.15) async -> GassiPredictionResult {
        let eventDates = events.compactMap(\.timestamp).sorted()
        let scheduleResult = GassiSchedulePredictor.prediction(eventDates: eventDates)

#if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, watchOS 26.0, *) {
            let aiResult = await GassiAIPredictor.nextDate(
                eventDates: eventDates,
                categoryID: events.first?.type?.id,
                dogID: events.first?.dog?.id
            )

            if case .success = aiResult {
                return aiResult
            }
        }
#endif

        return scheduleResult
    }

    static func nextDate(events: [GassiEvent], intervals: Int = 6, eventDays: Int, minProbability: Double = 0.15) async -> Date? {
        let result = await nextPrediction(events: events,
                                          intervals: intervals,
                                          eventDays: eventDays,
                                          minProbability: minProbability)
        guard case .success(let predictedDate) = result else { return nil }
        return predictedDate
    }
    
    func previous(events: [GassiEvent], dog: GassiDog? = nil, category: GassiType? = nil) -> GassiEvent? {
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp ?? .now > event2.timestamp ?? .now
        })
        var result: GassiEvent? = nil
        
        if let currentIndex = dscSortedEvents.firstIndex(of: self), currentIndex + 1 <= dscSortedEvents.count - 1 {
            for index in (currentIndex + 1)...(dscSortedEvents.count - 1) {
                if (category == nil || dscSortedEvents[index].type == category) &&
                   (dog == nil || dscSortedEvents[index].dog == dog) {
                    result = dscSortedEvents[index]
                    break
                }
            }
        }
        
        print(self.timestamp ?? "nil", result?.timestamp ?? "nil")
        return result
    }
    
    func distanceToPrevious(events: [GassiEvent], dog: GassiDog? = nil, category: GassiType? = nil) -> TimeInterval? {
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp ?? .now > event2.timestamp ?? .now
        })
        var result: TimeInterval? = nil
        
        if let previousEvent = self.previous(events: dscSortedEvents, dog: dog, category: category) {
            result = (previousEvent.timestamp ?? .now).distance(to: self.timestamp ?? .now)
        }
        
        return result
    }


}
