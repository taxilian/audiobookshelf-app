import Foundation

enum InterruptionAction: Equatable {
    case none
    case pause
    case resume
}

/// Pure decision logic for AVAudioSession interruptions, extracted for testability.
struct AudioInterruptionHandler {
    private(set) var wasPlayingBeforeInterruption = false

    mutating func handleInterruptionBegan(isPlaying: Bool, isAppSuspended: Bool) -> InterruptionAction {
        if isAppSuspended { return .none }
        if isPlaying { wasPlayingBeforeInterruption = true }
        return .pause
    }

    mutating func handleInterruptionEnded(shouldResume: Bool, isAppSuspended: Bool) -> InterruptionAction {
        defer { wasPlayingBeforeInterruption = false }
        if isAppSuspended { return .none }
        return (shouldResume || wasPlayingBeforeInterruption) ? .resume : .none
    }
}
