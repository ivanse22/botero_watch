import Foundation

public enum WallNumberResolver: Sendable {
    public static func normalizeKeypadInput(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        if trimmed.allSatisfy({ $0.isNumber }) {
            if trimmed.count == 1 { return "0" + trimmed }
            return trimmed
        }
        return trimmed
    }

    public static func lookup(_ catalog: MuseumCatalog, keypadDigits: String) -> Artwork? {
        let key = normalizeKeypadInput(keypadDigits)
        if key.isEmpty { return nil }
        if let exact = catalog.obras.first(where: { $0.wallNumber == key }) {
            return exact
        }
        if let byId = catalog.obras.first(where: { $0.id == key }) {
            return byId
        }
        return catalog.obras.first { normalizeKeypadInput($0.wallNumber) == key }
    }
}
