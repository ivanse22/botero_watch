import BoteroCore
import XCTest

final class RoutePlannerTests: XCTestCase {
    func testPlanFromPatioToMonaLisa() throws {
        let g = try MuseumRouteGraph.loadFromModuleBundle()
        let r = try RoutePlanner.plan(graph: g, from: "07", to: "01")
        XCTAssertTrue(r.nodeIds.first == "07")
        XCTAssertTrue(r.nodeIds.last == "01")
        XCTAssertGreaterThan(r.pathLengthMeters, 0)
        XCTAssertEqual(r.polylineMapUnits.count, r.nodeIds.count)
    }

    func testPlanToSecondFloor() throws {
        let g = try MuseumRouteGraph.loadFromModuleBundle()
        let r = try RoutePlanner.plan(graph: g, from: "07", to: "16")
        XCTAssertTrue(r.nodeIds.contains("09"))
        XCTAssertEqual(r.nodeIds.last, "16")
    }

    func testUnknownArtworkThrows() throws {
        let g = try MuseumRouteGraph.loadFromModuleBundle()
        XCTAssertThrowsError(try RoutePlanner.plan(graph: g, from: "07", to: "99"))
    }
}
