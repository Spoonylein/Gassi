//
//  NavigationController.swift
//  Gassi
//
//  Created by Jan Löffel on 02.08.23.
//

import Foundation
import SwiftUI

class NavigationController: ObservableObject {
    enum PredictionStatus {
        case idle
        case running
        case success
        case failure(String)

        var symbolName: String {
            switch self {
            case .idle:
                return "questionmark.circle"
            case .running:
                return "arrow.triangle.2.circlepath.circle"
            case .success:
                return "checkmark.circle.fill"
            case .failure:
                return "exclamationmark.triangle.fill"
            }
        }

        var color: Color {
            switch self {
            case .idle:
                return .secondary
            case .running:
                return .orange
            case .success:
                return .green
            case .failure:
                return .red
            }
        }

        var message: String {
            switch self {
            case .idle:
                return "Prediction idle"
            case .running:
                return "Recalculating predictions"
            case .success:
                return "Predictions successful"
            case .failure(let message):
                return message
            }
        }
    }
    
    @Published var path = NavigationPath()
    @Published private(set) var nextPredictionRefreshID = UUID()
    @Published private(set) var predictionStatus: PredictionStatus = .idle

    private var activePredictionRefreshID = UUID()
    private var expectedPredictionResults = 0
    private var receivedPredictionResults = 0
    private var successfulPredictionResults = 0
    private var firstFailureReason: String?

    func recalculateNextPrediction() {
        nextPredictionRefreshID = UUID()
    }

    func beginPredictionRefresh(expectedResults: Int) {
        activePredictionRefreshID = nextPredictionRefreshID
        expectedPredictionResults = expectedResults
        receivedPredictionResults = 0
        successfulPredictionResults = 0
        firstFailureReason = nil
        predictionStatus = expectedResults > 0 ? .running : .idle
    }

    func registerPredictionResult(for refreshID: UUID, result: GassiPredictionResult) {
        guard refreshID == activePredictionRefreshID else { return }
        guard receivedPredictionResults < expectedPredictionResults else { return }

        receivedPredictionResults += 1
        if case .success = result {
            successfulPredictionResults += 1
        } else if case .failure(let reason) = result, firstFailureReason == nil {
            firstFailureReason = reason.message
        }

        guard receivedPredictionResults == expectedPredictionResults else { return }
        predictionStatus = successfulPredictionResults == expectedPredictionResults ? .success : .failure(firstFailureReason ?? "Prediction failed")
    }
    
}
