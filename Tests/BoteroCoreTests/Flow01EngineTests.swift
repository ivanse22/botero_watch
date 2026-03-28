import BoteroCore
import XCTest

final class Flow01EngineTests: XCTestCase {
    private let engine = Flow01Engine()

    func testTapRutasFromMainGoesToChooseInputAndHaptic() {
        let s0 = Flow01State()
        let (s1, h) = engine.reduce(state: s0, event: .tapRutas)
        XCTAssertEqual(s1.phase, .chooseInputMethod)
        XCTAssertEqual(h, [.tappedRutas])
    }

    func testManualSelect_goesCalculatingThenFinishesRoute() {
        var s = Flow01State(phase: .manualList)
        var haptics: [Flow01HapticSignal] = []
        (s, haptics) = engine.reduce(state: s, event: .selectDestinationArtwork(id: "07"))
        XCTAssertEqual(s.phase, .calculatingRoute)
        XCTAssertTrue(haptics.isEmpty)

        (s, haptics) = engine.reduce(state: s, event: .routeCalculationFinished)
        XCTAssertEqual(s.phase, .directionalGuide)
        XCTAssertEqual(haptics, [.routeCalculated])
    }

    func testDeviationWhenPathOverThreeMeters() {
        let s = Flow01State(phase: .directionalGuide, destinationArtworkId: "01")
        let (s2, h) = engine.reduce(
            state: s,
            event: .navigationTick(distanceToPolylineMeters: 4, distanceToDestinationMeters: 10)
        )
        XCTAssertEqual(s2.phase, .deviationAlert)
        XCTAssertEqual(h, [.deviationAlert])
    }

    func testArrivalUnderOnePointFiveMeters() {
        let s = Flow01State(phase: .directionalGuide, destinationArtworkId: "01")
        let (s2, h) = engine.reduce(
            state: s,
            event: .navigationTick(distanceToPolylineMeters: 0.5, distanceToDestinationMeters: 1.2)
        )
        XCTAssertEqual(s2.phase, .arrivalSuccess)
        XCTAssertEqual(h, [.arrivalSuccess])
    }

    func testRoutePlanningFailedReturnsToManual() {
        let s = Flow01State(phase: .calculatingRoute, destinationArtworkId: "01")
        let (s2, h) = engine.reduce(state: s, event: .routePlanningFailed)
        XCTAssertEqual(s2.phase, .manualList)
        XCTAssertNil(s2.destinationArtworkId)
        XCTAssertTrue(h.isEmpty)
    }
}
