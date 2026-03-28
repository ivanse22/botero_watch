import BoteroCore
import SwiftUI

/// Raíz con los dos flujos: Flow 01 (rutas) y Flow 02 (número en pared).
public struct BoteroRootView: View {
    private let catalog: MuseumCatalog
    @StateObject private var flow01: Flow01ViewModel
    @StateObject private var wallModel: WallNumberViewModel

    public init(catalog: MuseumCatalog, positionSource: VisitorPositionProviding? = nil) {
        self.catalog = catalog
        _flow01 = StateObject(wrappedValue: Flow01ViewModel(positionSource: positionSource))
        _wallModel = StateObject(wrappedValue: WallNumberViewModel(catalog: catalog))
    }

    public static func loadDefault() throws -> BoteroRootView {
        let catalog = try MuseumCatalog.loadFromModuleBundle()
        return BoteroRootView(catalog: catalog)
    }

    public var body: some View {
        TabView {
            Flow01MenuView(model: flow01, catalog: catalog)
                .tabItem { Label("Rutas", systemImage: "map") }
            WallNumberFlowView(model: wallModel)
                .tabItem { Label("Número", systemImage: "number") }
        }
        .tint(BoteroTheme.brandPrimary)
        .background(BoteroTheme.bgBase)
    }
}
