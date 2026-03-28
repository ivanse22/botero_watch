import Foundation

public struct Flow01State: Equatable, Sendable {
    public var phase: Flow01Phase
    public var destinationArtworkId: String?
    public var voiceInputAvailable: Bool

    public init(
        phase: Flow01Phase = .mainMenu,
        destinationArtworkId: String? = nil,
        voiceInputAvailable: Bool = true
    ) {
        self.phase = phase
        self.destinationArtworkId = destinationArtworkId
        self.voiceInputAvailable = voiceInputAvailable
    }
}
