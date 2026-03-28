import Foundation

public enum Flow01Event: Equatable, Sendable {
    case tapRutas
    case chooseManualInput
    case chooseVoiceInput
    case voiceHeardExpressRoute
    case selectDestinationArtwork(id: String)
    case routeCalculationFinished
    /// Si no hay trayecto en el grafo (obra desconocida o grafo incompleto).
    case routePlanningFailed
    case navigationTick(distanceToPolylineMeters: Double?, distanceToDestinationMeters: Double?)
    case tapRecalculateRoute
    case acknowledgeArrival
    case goToMainMenu
}
