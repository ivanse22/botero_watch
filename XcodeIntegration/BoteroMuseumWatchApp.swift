// Copia este archivo al target **App** de watchOS en Xcode (o añádelo como referencia).
// Añade el paquete local `BoteroMuseum` y enlaza el producto **BoteroWatchUI** + **BoteroCore**.

import BoteroCore
import BoteroWatchUI
import SwiftUI

@main
struct BoteroMuseumWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchShellView()
        }
    }
}

private struct WatchShellView: View {
    private let tracker = CoreLocationVisitorTracker()
    @State private var root: BoteroRootView?
    @State private var loadError: String?

    var body: some View {
        Group {
            if let root {
                root
            } else if let loadError {
                Text(loadError)
                    .font(.caption2)
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                tracker.start()
                let catalog = try MuseumCatalog.loadFromModuleBundle()
                root = BoteroRootView(catalog: catalog, positionSource: tracker)
            } catch {
                loadError = error.localizedDescription
            }
        }
        .onDisappear {
            tracker.stop()
        }
    }
}
