import Foundation

/// Señales de haptic mapeadas 1:1 al flujograma Flow 01.
public enum Flow01HapticSignal: Equatable, Sendable, CaseIterable {
    case tappedRutas
    case routeCalculated
    case deviationAlert
    case tappedRecalculate
    case arrivalSuccess
}
