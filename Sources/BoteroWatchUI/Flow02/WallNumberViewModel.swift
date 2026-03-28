import BoteroCore
import Foundation
import SwiftUI

@MainActor
public final class WallNumberViewModel: ObservableObject {
    @Published public var digits: String = ""
    @Published public private(set) var resolved: Artwork?
    @Published public private(set) var showNotFound = false

    private let catalog: MuseumCatalog

    public init(catalog: MuseumCatalog) {
        self.catalog = catalog
    }

    public func appendDigit(_ n: Int) {
        guard (0 ... 9).contains(n) else { return }
        if digits.count >= 3 { return }
        digits += String(n)
    }

    public func deleteLast() {
        guard !digits.isEmpty else { return }
        digits.removeLast()
    }

    public func clearEntry() {
        digits = ""
        showNotFound = false
    }

    public func submit() {
        showNotFound = false
        resolved = WallNumberResolver.lookup(catalog, keypadDigits: digits)
        if resolved == nil, !digits.isEmpty {
            showNotFound = true
        }
    }

    public func dismissResult() {
        resolved = nil
        clearEntry()
    }
}
