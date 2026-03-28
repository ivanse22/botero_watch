import BoteroCore
import SwiftUI

public struct WallNumberFlowView: View {
    @ObservedObject var model: WallNumberViewModel

    public init(model: WallNumberViewModel) {
        self.model = model
    }

    public var body: some View {
        Group {
            if let artwork = model.resolved {
                ArtworkDetailView(artwork: artwork, onDone: { model.dismissResult() })
            } else {
                VStack(spacing: 10) {
                    Text("Número en la pared")
                        .font(.headline)
                        .foregroundStyle(BoteroTheme.textPrimary)
                    Text(model.digits.isEmpty ? "— —" : model.digits)
                        .font(.title2)
                        .monospacedDigit()
                        .foregroundStyle(BoteroTheme.brandPrimary)
                    if model.showNotFound {
                        Text("No encontramos esa obra.")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                    Text("Ejemplo: 01, 07, 12")
                        .font(.caption2)
                        .foregroundStyle(BoteroTheme.textSecondary)
                    NumericPadView(model: model)
                    HStack {
                        Button("Limpiar") { model.clearEntry() }
                            .tint(BoteroTheme.textSecondary)
                        Button("⌫") { model.deleteLast() }
                            .tint(BoteroTheme.textSecondary)
                        Button("OK") { model.submit() }
                            .buttonStyle(.borderedProminent)
                            .tint(BoteroTheme.brandPrimary)
                    }
                    .font(.caption2)
                }
                .padding(.vertical, 4)
                .padding(6)
                .background(BoteroTheme.bgBase)
                .boteroCard()
            }
        }
    }
}

private struct NumericPadView: View {
    @ObservedObject var model: WallNumberViewModel

    private let rows: [[Int?]] = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [nil, 0, nil],
    ]

    var body: some View {
        VStack(spacing: 6) {
            ForEach(0 ..< rows.count, id: \.self) { r in
                HStack(spacing: 6) {
                    ForEach(0 ..< rows[r].count, id: \.self) { c in
                        let v = rows[r][c]
                        if let v {
                            Button("\(v)") { model.appendDigit(v) }
                                .frame(maxWidth: .infinity)
                                .tint(BoteroTheme.bgCardRaised)
                        } else {
                            Spacer(minLength: 8)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
}

private struct ArtworkDetailView: View {
    let artwork: Artwork
    var onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(artwork.titulo)
                    .font(.headline)
                    .foregroundStyle(BoteroTheme.textPrimary)
                Text("\(artwork.sala) · \(artwork.año)")
                    .font(.caption2)
                    .foregroundStyle(BoteroTheme.textSecondary)
                Text(artwork.tecnica)
                    .font(.caption2)
                    .foregroundStyle(BoteroTheme.textSecondary)
                Text(artwork.desc)
                    .font(.caption2)
                    .foregroundStyle(BoteroTheme.textPrimary)
                Divider()
                Text(artwork.iaRespuesta)
                    .font(.caption2)
                    .foregroundStyle(BoteroTheme.textSecondary)
                Button("Otra obra") { onDone() }
                    .padding(.top, 6)
                    .tint(BoteroTheme.brandPrimary)
            }
            .padding(8)
            .background(BoteroTheme.bgBase)
            .boteroCard()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
