import BoteroCore
import Foundation
#if os(watchOS)
import WatchKit
#endif

public enum Flow01HapticsPlayer {
    public static func play(_ signal: Flow01HapticSignal) {
        #if os(watchOS)
        let device = WKInterfaceDevice.current()
        switch signal {
        case .tappedRutas:
            device.play(.click)
        case .routeCalculated:
            device.play(.directionUp)
        case .deviationAlert:
            device.play(.notification)
        case .tappedRecalculate:
            device.play(.click)
        case .arrivalSuccess:
            device.play(.success)
        }
        #endif
    }

    public static func play(sequence: [Flow01HapticSignal]) {
        sequence.forEach { play($0) }
    }
}
