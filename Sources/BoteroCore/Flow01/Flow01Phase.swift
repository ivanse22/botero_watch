import Foundation

/// Fases alineadas a P01, D01, P02 / P02b, SYS01, P03, N01, N02, Fin.
public enum Flow01Phase: String, Sendable, Equatable, CaseIterable {
    case mainMenu
    case chooseInputMethod
    case manualList
    case voiceListening
    case calculatingRoute
    case directionalGuide
    case deviationAlert
    case arrivalSuccess
    case readyToScan
}
