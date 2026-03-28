import Foundation

public enum RouteGeometry: Sendable {
    public static func minDistanceFromPointToPolylineMapUnits(_ p: MapPoint, polyline: [MapPoint]) -> Double {
        guard polyline.count >= 2 else {
            if let a = polyline.first { return p.distance(to: a) }
            return 0
        }
        var best = Double.greatestFiniteMagnitude
        for i in 0 ..< (polyline.count - 1) {
            let d = distancePointToSegment(p, polyline[i], polyline[i + 1])
            best = min(best, d)
        }
        return best
    }

    public static func distanceToDestinationMeters(
        _ p: MapPoint,
        destination: MapPoint,
        metersPerUnit: Double
    ) -> Double {
        p.distance(to: destination) * metersPerUnit
    }

    public static func pointAlongPolyline(
        metersFromStart: Double,
        polyline: [MapPoint],
        metersPerUnit: Double
    ) -> MapPoint? {
        guard polyline.count >= 2, metersPerUnit > 0 else { return polyline.first }
        var remaining = metersFromStart / metersPerUnit
        for i in 0 ..< (polyline.count - 1) {
            let a = polyline[i]
            let b = polyline[i + 1]
            let segLen = a.distance(to: b)
            if remaining <= segLen {
                let t = segLen > 0 ? remaining / segLen : 0
                return MapPoint(x: a.x + t * (b.x - a.x), y: a.y + t * (b.y - a.y))
            }
            remaining -= segLen
        }
        return polyline.last
    }

    public static func totalPolylineLengthMeters(polyline: [MapPoint], metersPerUnit: Double) -> Double {
        guard polyline.count >= 2 else { return 0 }
        let u = zip(polyline, polyline.dropFirst()).map { $0.distance(to: $1) }.reduce(0, +)
        return u * metersPerUnit
    }

    private static func distancePointToSegment(_ p: MapPoint, _ a: MapPoint, _ b: MapPoint) -> Double {
        let abx = b.x - a.x
        let aby = b.y - a.y
        let apx = p.x - a.x
        let apy = p.y - a.y
        let ab2 = abx * abx + aby * aby
        if ab2 <= 1e-9 { return p.distance(to: a) }
        var t = (apx * abx + apy * aby) / ab2
        t = max(0, min(1, t))
        let cx = a.x + t * abx
        let cy = a.y + t * aby
        return p.distance(to: MapPoint(x: cx, y: cy))
    }
}
