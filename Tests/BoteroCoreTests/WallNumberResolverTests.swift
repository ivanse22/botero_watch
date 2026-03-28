import BoteroCore
import XCTest

final class WallNumberResolverTests: XCTestCase {
    func testNormalizeSingleDigit() {
        XCTAssertEqual(WallNumberResolver.normalizeKeypadInput("1"), "01")
    }

    func testLookupByWallNumber() throws {
        let catalog = try MuseumCatalog.loadFromModuleBundle()
        let o = WallNumberResolver.lookup(catalog, keypadDigits: "01")
        XCTAssertEqual(o?.titulo, "Mona Lisa")
    }

    func testLookupInvalid() throws {
        let catalog = try MuseumCatalog.loadFromModuleBundle()
        XCTAssertNil(WallNumberResolver.lookup(catalog, keypadDigits: "99"))
    }
}
