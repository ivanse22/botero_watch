import Foundation

public struct PlannedRoute: Sendable, Equatable {
    public var nodeIds: [String]
    public var polylineMapUnits: [MapPoint]
    public var pathLengthMeters: Double
    public var destinationMapPoint: MapPoint

    public init(
        nodeIds: [String],
        polylineMapUnits: [MapPoint],
        pathLengthMeters: Double,
        destinationMapPoint: MapPoint
    ) {
        self.nodeIds = nodeIds
        self.polylineMapUnits = polylineMapUnits
        self.pathLengthMeters = pathLengthMeters
        self.destinationMapPoint = destinationMapPoint
    }
}

public enum RoutePlanner: Sendable {
    public static func plan(
        graph: MuseumRouteGraph,
        from startNodeId: String,
        to destinationArtworkId: String
    ) throws -> PlannedRoute {
        let nodeById = Dictionary(uniqueKeysWithValues: graph.nodes.map { ($0.id, $0) })
        guard nodeById[startNodeId] != nil else { throw RouteGraphError.unknownNode(startNodeId) }
        guard let goalNode = graph.nodes.first(where: {
            $0.artworkId == destinationArtworkId || $0.id == destinationArtworkId
        }) else {
            throw RouteGraphError.unknownArtwork(destinationArtworkId)
        }
        let goalId = goalNode.id

        var adj: [String: [(String, Double)]] = [:]
        for e in graph.edges {
            let a = nodeById[e.from]!.mapPoint
            let b = nodeById[e.to]!.mapPoint
            let w = a.distance(to: b)
            adj[e.from, default: []].append((e.to, w))
            adj[e.to, default: []].append((e.from, w))
        }

        var dist: [String: Double] = [startNodeId: 0]
        var prev: [String: String] = [:]
        var visited: Set<String> = []

        while let u = dist.filter({ !visited.contains($0.key) }).min(by: { $0.value < $1.value })?.key {
            let du = dist[u]!
            visited.insert(u)
            if u == goalId { break }
            for (v, w) in adj[u, default: []] {
                let nd = du + w
                if dist[v] == nil || nd < dist[v]! {
                    dist[v] = nd
                    prev[v] = u
                }
            }
        }

        guard dist[goalId] != nil else { throw RouteGraphError.noPath }

        var chain: [String] = []
        var cur: String? = goalId
        while let c = cur {
            chain.append(c)
            cur = c == startNodeId ? nil : prev[c]
        }
        chain.reverse()

        let points = chain.compactMap { nodeById[$0]?.mapPoint }
        let lengthMap = zip(points, points.dropFirst()).map { $0.distance(to: $1) }.reduce(0, +)
        let lengthMeters = lengthMap * graph.map.metersPerUnit
        let dest = nodeById[goalId]!.mapPoint

        return PlannedRoute(
            nodeIds: chain,
            polylineMapUnits: points,
            pathLengthMeters: lengthMeters,
            destinationMapPoint: dest
        )
    }
}
