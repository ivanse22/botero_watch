import Foundation

/// Motor puro del Flow 01: transiciones + señales hápticas.
public struct Flow01Engine: Sendable {
    public var thresholds: NavigationThresholds

    public init(thresholds: NavigationThresholds = NavigationThresholds()) {
        self.thresholds = thresholds
    }

    public func reduce(state: Flow01State, event: Flow01Event) -> (Flow01State, [Flow01HapticSignal]) {
        var next = state
        var signals: [Flow01HapticSignal] = []

        switch event {
        case .tapRutas where state.phase == .mainMenu:
            signals.append(.tappedRutas)
            next.phase = .chooseInputMethod

        case .chooseManualInput where state.phase == .chooseInputMethod:
            next.phase = .manualList

        case .chooseVoiceInput where state.phase == .chooseInputMethod:
            if state.voiceInputAvailable {
                next.phase = .voiceListening
            } else {
                next.phase = .manualList
            }

        case .voiceHeardExpressRoute where state.phase == .voiceListening:
            next.destinationArtworkId = "01"
            next.phase = .calculatingRoute

        case .selectDestinationArtwork(let id) where state.phase == .manualList:
            next.destinationArtworkId = id
            next.phase = .calculatingRoute

        case .routeCalculationFinished where state.phase == .calculatingRoute:
            signals.append(.routeCalculated)
            next.phase = .directionalGuide

        case .routePlanningFailed where state.phase == .calculatingRoute:
            next.phase = .manualList
            next.destinationArtworkId = nil

        case .navigationTick(let toPath, let toDest) where state.phase == .directionalGuide:
            let pathMeters = toPath ?? 0
            let destMeters = toDest ?? .greatestFiniteMagnitude
            if pathMeters > thresholds.maxDeviationFromRouteMeters {
                next.phase = .deviationAlert
                signals.append(.deviationAlert)
            } else if destMeters < thresholds.arrivalRadiusMeters {
                next.phase = .arrivalSuccess
                signals.append(.arrivalSuccess)
            }

        case .tapRecalculateRoute where state.phase == .deviationAlert:
            signals.append(.tappedRecalculate)
            next.phase = .calculatingRoute

        case .acknowledgeArrival where state.phase == .arrivalSuccess:
            next.phase = .readyToScan

        case .goToMainMenu:
            next = Flow01State(voiceInputAvailable: state.voiceInputAvailable)

        default:
            break
        }

        return (next, signals)
    }
}
