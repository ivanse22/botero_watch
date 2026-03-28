import Foundation

/// Punto en el mismo espacio que el viewBox del plano (p. ej. 340×280).
public struct MapPoint: Codable, Sendable, Hashable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public func distance(to other: MapPoint) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        return (dx * dx + dy * dy).squareRoot()
    }
}

public struct RouteMapConfig: Codable, Sendable {
    public var width: Double
    public var height: Double
    public var metersPerUnit: Double
    public var defaultStartNodeId: String

    public init(width: Double, height: Double, metersPerUnit: Double, defaultStartNodeId: String) {
        self.width = width
        self.height = height
        self.metersPerUnit = metersPerUnit
        self.defaultStartNodeId = defaultStartNodeId
    }
}

public struct RouteGraphNode: Codable, Sendable, Hashable {
    public var id: String
    public var artworkId: String?
    public var x: Double
    public var y: Double

    public init(id: String, artworkId: String?, x: Double, y: Double) {
        self.id = id
        self.artworkId = artworkId
        self.x = x
        self.y = y
    }

    public var mapPoint: MapPoint { MapPoint(x: x, y: y) }
}

public struct RouteGraphEdge: Codable, Sendable, Hashable {
    public var from: String
    public var to: String

    public init(from: String, to: String) {
        self.from = from
        self.to = to
    }
}

public struct MuseumRouteGraph: Codable, Sendable {
    public var map: RouteMapConfig
    public var nodes: [RouteGraphNode]
    public var edges: [RouteGraphEdge]

    public init(map: RouteMapConfig, nodes: [RouteGraphNode], edges: [RouteGraphEdge]) {
        self.map = map
        self.nodes = nodes
        self.edges = edges
    }

    public static func loadFromModuleBundle() throws -> MuseumRouteGraph {
        guard let url = Bundle.module.url(forResource: "museum_route_graph", withExtension: "json") else {
            throw RouteGraphError.missingResource
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(MuseumRouteGraph.self, from: data)
    }
}

public enum RouteGraphError: Error {
    case missingResource
    case unknownNode(String)
    case noPath
    case unknownArtwork(String)
}

/// Fuente opcional de posición del visitante en coordenadas de plano (metros/enlaces indoor).
/// Si `visitorMapPointIfAvailable()` devuelve `nil`, la UI simula el avance por la polilínea.
public protocol VisitorPositionProviding: AnyObject {
    func visitorMapPointIfAvailable() -> MapPoint?
}
