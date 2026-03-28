import Foundation

/// Umbrales del Flow 01 (calibrables in situ).
public struct NavigationThresholds: Sendable, Equatable {
    public var maxDeviationFromRouteMeters: Double
    public var arrivalRadiusMeters: Double

    public init(maxDeviationFromRouteMeters: Double = 3, arrivalRadiusMeters: Double = 1.5) {
        self.maxDeviationFromRouteMeters = maxDeviationFromRouteMeters
        self.arrivalRadiusMeters = arrivalRadiusMeters
    }
}
