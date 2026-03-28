import BoteroCore
import SwiftUI

/// Journey único de visita en dos etapas: llegar a la obra y consultar su número.
public struct BoteroRootView: View {
    private enum Stage: String {
        case intro = "Inicio"
        case route = "Ruta"
        case number = "Consulta"
    }

    private let catalog: MuseumCatalog
    @StateObject private var flow01: Flow01ViewModel
    @StateObject private var wallModel: WallNumberViewModel
    @State private var stage: Stage = .intro

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
        VStack(spacing: 8) {
            header
            content
        }
        .tint(BoteroTheme.brandPrimary)
        .background(BoteroTheme.bgBase)
        .onChange(of: flow01.state.phase) { _, newPhase in
            if newPhase == .readyToScan, stage == .route {
                wallModel.preloadFromArtworkId(flow01.state.destinationArtworkId)
            }
        }
    }

    @ViewBuilder
    private var header: some View {
        HStack {
            Text("Botero Watch")
                .font(.caption)
                .foregroundStyle(BoteroTheme.textPrimary)
            Spacer()
            Text(stage.rawValue)
                .font(.caption2)
                .foregroundStyle(BoteroTheme.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(BoteroTheme.bgCardRaised)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private var content: some View {
        switch stage {
        case .intro:
            introView
        case .route:
            routeView
        case .number:
            numberView
        }
    }

    private var introView: some View {
        VStack(spacing: 10) {
            Text("Tu visita en 2 pasos")
                .font(.headline)
                .foregroundStyle(BoteroTheme.textPrimary)
            Text("1) Llega a la obra\\n2) Consulta su numero")
                .font(.caption2)
                .foregroundStyle(BoteroTheme.textSecondary)
                .multilineTextAlignment(.center)
            Button("Comenzar visita") {
                stage = .route
            }
            .buttonStyle(.borderedProminent)
            .tint(BoteroTheme.brandPrimary)
        }
        .padding(8)
        .boteroCard()
    }

    private var routeView: some View {
        VStack(spacing: 8) {
            Flow01MenuView(model: flow01, catalog: catalog)
            if flow01.state.phase == .readyToScan {
                Button("Consultar esta obra") {
                    wallModel.preloadFromArtworkId(flow01.state.destinationArtworkId)
                    stage = .number
                }
                .buttonStyle(.borderedProminent)
                .tint(BoteroTheme.brandPrimary)
            } else {
                Text(routePhaseLabel)
                    .font(.caption2)
                    .foregroundStyle(BoteroTheme.textSecondary)
            }
        }
    }

    private var numberView: some View {
        VStack(spacing: 8) {
            WallNumberFlowView(model: wallModel)
            HStack {
                Button("Volver a ruta") {
                    stage = .route
                }
                .buttonStyle(.bordered)
                .tint(BoteroTheme.textSecondary)
                Button("Inicio") {
                    stage = .intro
                }
                .buttonStyle(.bordered)
                .tint(BoteroTheme.textSecondary)
            }
        }
    }

    private var routePhaseLabel: String {
        switch flow01.state.phase {
        case .mainMenu:
            return "Estado: iniciar ruta"
        case .chooseInputMethod:
            return "Estado: elegir modo"
        case .manualList:
            return "Estado: elegir obra"
        case .voiceListening:
            return "Estado: escucha de voz (demo)"
        case .calculatingRoute:
            return "Estado: calculando"
        case .directionalGuide:
            return "Estado: guiando"
        case .deviationAlert:
            return "Estado: desvio detectado"
        case .arrivalSuccess:
            return "Estado: llegada"
        case .readyToScan:
            return "Estado: listo para consultar"
        }
    }
}
