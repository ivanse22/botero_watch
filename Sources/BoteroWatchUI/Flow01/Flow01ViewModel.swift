import BoteroCore
import Combine
import Foundation
import SwiftUI

@MainActor
public final class Flow01ViewModel: ObservableObject {
    public enum PositionMode: String, CaseIterable, Sendable {
        case simulated = "Simulado"
        case deviceLocation = "GPS"
    }

    @Published public private(set) var state: Flow01State
    @Published public private(set) var distanceToPolylineMeters: Double = 0
    @Published public private(set) var distanceToDestinationMeters: Double = 0
    @Published public private(set) var navigationHint: String = ""
    @Published public private(set) var activeRoute: PlannedRoute?
    @Published public private(set) var routeGraph: MuseumRouteGraph?
    @Published public private(set) var routeErrorMessage: String?
    @Published public private(set) var positionMode: PositionMode = .simulated
    @Published public private(set) var isUsingFallbackSimulation = false

    public weak var positionSource: VisitorPositionProviding?

    private var engine: Flow01Engine
    private var navigationTimer: Timer?
    private var walkedMetersAlongRoute: Double = 0
    private var simulatedDeviationMeters: Double = 0
    private let walkSpeedMetersPerSecond: Double = 0.75

    public init(
        state: Flow01State = Flow01State(),
        engine: Flow01Engine = Flow01Engine(),
        positionSource: VisitorPositionProviding? = nil
    ) {
        self.state = state
        self.engine = engine
        self.positionSource = positionSource
    }

    public func setPositionMode(_ mode: PositionMode) {
        positionMode = mode
    }

    public func send(_ event: Flow01Event) {
        let (next, haptics) = engine.reduce(state: state, event: event)
        state = next
        haptics.forEach(Flow01HapticsPlayer.play)

        switch event {
        case .selectDestinationArtwork, .voiceHeardExpressRoute:
            routeErrorMessage = nil
            finishRouteCalculationSoon()
        case .tapRecalculateRoute:
            simulatedDeviationMeters = 0
            routeErrorMessage = nil
            finishRouteCalculationSoon()
        default:
            break
        }

        if next.phase == .directionalGuide {
            startGuidanceLoop()
        } else if next.phase != .directionalGuide {
            stopGuidanceLoop()
        }
    }

    private func loadGraphIfNeeded() throws -> MuseumRouteGraph {
        if let g = routeGraph { return g }
        let g = try MuseumRouteGraph.loadFromModuleBundle()
        routeGraph = g
        return g
    }

    private func finishRouteCalculationSoon() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 320_000_000)
            guard state.phase == .calculatingRoute else { return }
            guard let destId = state.destinationArtworkId else {
                applyPlanningFailed()
                return
            }
            do {
                let graph = try loadGraphIfNeeded()
                let plan = try RoutePlanner.plan(
                    graph: graph,
                    from: graph.map.defaultStartNodeId,
                    to: destId
                )
                activeRoute = plan
                navigationHint = hint(for: plan, graph: graph)
                walkedMetersAlongRoute = 0
                routeErrorMessage = nil
                send(.routeCalculationFinished)
            } catch {
                activeRoute = nil
                routeErrorMessage = "No pudimos calcular la ruta. Elige otra obra."
                applyPlanningFailed()
            }
        }
    }

    private func applyPlanningFailed() {
        let (next, _) = engine.reduce(state: state, event: .routePlanningFailed)
        state = next
    }

    private func hint(for plan: PlannedRoute, graph: MuseumRouteGraph) -> String {
        let _ = graph
        let hops = max(0, plan.nodeIds.count - 1)
        return "\(hops) tramos · \(Int(plan.pathLengthMeters)) m"
    }

    private func startGuidanceLoop() {
        navigationTimer?.invalidate()
        guard let route = activeRoute, let graph = routeGraph else { return }
        distanceToPolylineMeters = 0
        distanceToDestinationMeters = RouteGeometry.distanceToDestinationMeters(
            route.polylineMapUnits.first ?? route.destinationMapPoint,
            destination: route.destinationMapPoint,
            metersPerUnit: graph.map.metersPerUnit
        )

        let interval: TimeInterval = 1.0
        navigationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.tickNavigation(every: interval)
            }
        }
        if let t = navigationTimer {
            RunLoop.main.add(t, forMode: .common)
        }
    }

    private func stopGuidanceLoop() {
        navigationTimer?.invalidate()
        navigationTimer = nil
    }

    private func tickNavigation(every interval: TimeInterval) {
        guard state.phase == .directionalGuide, let route = activeRoute, let graph = routeGraph else { return }

        let mpu = graph.map.metersPerUnit
        let pos: MapPoint

        if positionMode == .deviceLocation, let ext = positionSource?.visitorMapPointIfAvailable() {
            pos = ext
            isUsingFallbackSimulation = false
        } else {
            isUsingFallbackSimulation = positionMode == .deviceLocation
            walkedMetersAlongRoute = min(
                walkedMetersAlongRoute + walkSpeedMetersPerSecond * interval,
                route.pathLengthMeters
            )
            pos = RouteGeometry.pointAlongPolyline(
                metersFromStart: walkedMetersAlongRoute,
                polyline: route.polylineMapUnits,
                metersPerUnit: mpu
            ) ?? route.destinationMapPoint
        }

        let crossTrackMap = RouteGeometry.minDistanceFromPointToPolylineMapUnits(pos, polyline: route.polylineMapUnits)
        let distPath = crossTrackMap * mpu + simulatedDeviationMeters
        let distDest = RouteGeometry.distanceToDestinationMeters(
            pos,
            destination: route.destinationMapPoint,
            metersPerUnit: mpu
        )

        distanceToPolylineMeters = distPath
        distanceToDestinationMeters = distDest

        send(
            .navigationTick(
                distanceToPolylineMeters: distPath,
                distanceToDestinationMeters: distDest
            )
        )
    }

    public func debugTriggerDeviation() {
        simulatedDeviationMeters = 4
        tickNavigation(every: 0.1)
    }

    public func debugForceArrival() {
        distanceToDestinationMeters = 0.5
        send(
            .navigationTick(
                distanceToPolylineMeters: distanceToPolylineMeters,
                distanceToDestinationMeters: 0.5
            )
        )
    }

    deinit {
        navigationTimer?.invalidate()
    }
}
