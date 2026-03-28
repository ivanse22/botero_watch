import BoteroCore
import SwiftUI

public struct Flow01MenuView: View {
    @ObservedObject var model: Flow01ViewModel
    let catalog: MuseumCatalog

    public init(model: Flow01ViewModel, catalog: MuseumCatalog) {
        self.model = model
        self.catalog = catalog
    }

    public var body: some View {
        Group {
            switch model.state.phase {
            case .mainMenu:
                VStack(spacing: 12) {
                    Text("Museo Botero")
                        .font(.headline)
                        .foregroundStyle(BoteroTheme.textPrimary)
                    Button("Rutas") {
                        model.send(.tapRutas)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(BoteroTheme.brandPrimary)
                    HStack(spacing: 6) {
                        Text("Modo:")
                            .font(.caption2)
                            .foregroundStyle(BoteroTheme.textSecondary)
                        Button(model.positionMode.rawValue) {
                            let next: Flow01ViewModel.PositionMode =
                                model.positionMode == .simulated ? .deviceLocation : .simulated
                            model.setPositionMode(next)
                        }
                        .font(.caption2)
                    }
                }
                .boteroCard()
            case .chooseInputMethod:
                VStack(spacing: 10) {
                    Text("¿Cómo eliges la obra?")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BoteroTheme.textPrimary)
                    Button("Lista / teclado") {
                        model.send(.chooseManualInput)
                    }
                    .tint(BoteroTheme.brandPrimary)
                    if model.state.voiceInputAvailable {
                        Button("Voz") {
                            model.send(.chooseVoiceInput)
                        }
                        .tint(BoteroTheme.brandPrimary)
                    }
                    Button("Menú") {
                        model.send(.goToMainMenu)
                    }
                    .font(.caption2)
                }
                .boteroCard()
            case .manualList:
                ManualDestinationsList(model: model, catalog: catalog)
            case .voiceListening:
                VStack(spacing: 10) {
                    Text("Di: “Ruta express”")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BoteroTheme.textPrimary)
                    Button("Simular reconocimiento") {
                        model.send(.voiceHeardExpressRoute)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(BoteroTheme.brandPrimary)
                    Button("Cancelar") {
                        model.send(.goToMainMenu)
                    }
                    .font(.caption2)
                }
                .boteroCard()
            case .calculatingRoute:
                VStack(spacing: 8) {
                    ProgressView("Calculando ruta…")
                    Text("Usando nodos del plano del museo")
                        .font(.caption2)
                        .foregroundStyle(BoteroTheme.textSecondary)
                }
                .boteroCard()
            case .directionalGuide:
                DirectionalGuideView(model: model)
            case .deviationAlert:
                VStack(spacing: 10) {
                    Text("Te alejaste de la ruta")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BoteroTheme.textPrimary)
                    Button("Recalcular") {
                        model.send(.tapRecalculateRoute)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(BoteroTheme.brandPrimary)
                    Button("Probar desvío (demo)") {
                        model.debugTriggerDeviation()
                    }
                    .font(.caption2)
                }
                .boteroCard()
            case .arrivalSuccess:
                VStack(spacing: 10) {
                    Text("Llegaste")
                        .font(.headline)
                        .foregroundStyle(BoteroTheme.brandGreen)
                    Text("Listo para consultar la obra")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BoteroTheme.textPrimary)
                    Button("Continuar") {
                        model.send(.acknowledgeArrival)
                    }
                    .tint(BoteroTheme.brandPrimary)
                }
                .boteroCard()
            case .readyToScan:
                VStack(spacing: 8) {
                    Text("Listo")
                        .font(.headline)
                        .foregroundStyle(BoteroTheme.textPrimary)
                    Text("Usa “Consultar número” en el menú principal.")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BoteroTheme.textSecondary)
                    Button("Menú") {
                        model.send(.goToMainMenu)
                    }
                }
                .boteroCard()
            }
        }
        .padding(6)
        .background(BoteroTheme.bgBase)
        .padding(.vertical, 4)
    }
}

private struct ManualDestinationsList: View {
    @ObservedObject var model: Flow01ViewModel
    let catalog: MuseumCatalog

    var body: some View {
        List {
            if let error = model.routeErrorMessage {
                Section {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            Section {
                ForEach(catalog.obras, id: \.id) { obra in
                    Button {
                        model.send(.selectDestinationArtwork(id: obra.id))
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(obra.wallNumber) · \(obra.titulo)")
                                .foregroundStyle(BoteroTheme.textPrimary)
                            Text("\(obra.sala) · Piso \(obra.piso)")
                                .font(.caption2)
                                .foregroundStyle(BoteroTheme.textSecondary)
                        }
                    }
                }
            }
            Section {
                Button("Menú") { model.send(.goToMainMenu) }
                    .font(.caption2)
            }
        }
    }
}

private struct DirectionalGuideView: View {
    @ObservedObject var model: Flow01ViewModel

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "location.north.line.fill")
                .font(.title)
                .foregroundStyle(BoteroTheme.brandPrimary)
            Text("Sigue la ruta")
                .font(.caption)
                .foregroundStyle(BoteroTheme.textPrimary)
            if let id = model.state.destinationArtworkId {
                Text("Hacia obra \(id)")
                    .font(.caption2)
                    .foregroundStyle(BoteroTheme.textSecondary)
            }
            Text("Ruta orientativa")
                .font(.caption2)
                .foregroundStyle(BoteroTheme.textSecondary)
            if !model.navigationHint.isEmpty {
                Text(model.navigationHint)
                    .font(.caption2)
                    .foregroundStyle(BoteroTheme.textSecondary)
            }
            if model.positionMode == .deviceLocation && model.isUsingFallbackSimulation {
                Text("GPS sin calibrar, usando simulación")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.orange)
            }
            Text(String(format: "~%.1f m al destino", model.distanceToDestinationMeters))
                .font(.caption2)
                .monospacedDigit()
            Text(String(format: "Desvio ruta: %.1f m", model.distanceToPolylineMeters))
                .font(.caption2)
                .foregroundStyle(BoteroTheme.textDisabled)
                .monospacedDigit()
            HStack {
                Button("Desvío") { model.debugTriggerDeviation() }
                    .font(.caption2)
                    .tint(BoteroTheme.brandPrimary)
                Button("Llegada") { model.debugForceArrival() }
                    .font(.caption2)
                    .tint(BoteroTheme.brandGreen)
            }
            Button("Menú") { model.send(.goToMainMenu) }
                .font(.caption2)
                .foregroundStyle(BoteroTheme.textSecondary)
        }
        .boteroCard()
    }
}
