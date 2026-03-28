import BoteroCore
import Foundation

#if os(watchOS)
import CoreLocation

public final class CoreLocationVisitorTracker: NSObject, VisitorPositionProviding, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    override public init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    public private(set) var lastLocation: CLLocation?

    public func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    public func stop() {
        manager.stopUpdatingLocation()
    }

    public func visitorMapPointIfAvailable() -> MapPoint? {
        nil
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
}

#else

public final class CoreLocationVisitorTracker: VisitorPositionProviding {
    public init() {}
    public func visitorMapPointIfAvailable() -> MapPoint? { nil }
}

#endif
