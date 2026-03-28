import SwiftUI

enum BoteroTheme {
    static let bgBase = Color(red: 9 / 255, green: 8 / 255, blue: 7 / 255)
    static let bgCard = Color(red: 17 / 255, green: 14 / 255, blue: 12 / 255)
    static let bgCardRaised = Color(red: 22 / 255, green: 19 / 255, blue: 17 / 255)
    static let textPrimary = Color(red: 253 / 255, green: 248 / 255, blue: 245 / 255)
    static let textSecondary = Color(red: 163 / 255, green: 153 / 255, blue: 145 / 255)
    static let textDisabled = Color(red: 103 / 255, green: 93 / 255, blue: 85 / 255)
    static let brandPrimary = Color(red: 192 / 255, green: 57 / 255, blue: 43 / 255)
    static let brandGreen = Color(red: 46 / 255, green: 139 / 255, blue: 87 / 255)
    static let borderSubtle = Color.white.opacity(0.06)
    static let borderMedium = Color.white.opacity(0.12)
}

struct BoteroCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(BoteroTheme.bgCard)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(BoteroTheme.borderMedium, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    func boteroCard() -> some View {
        modifier(BoteroCard())
    }
}
