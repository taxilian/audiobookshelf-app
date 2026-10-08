//
//  ProgressRestoreResolver.swift
//  App
//

import Foundation

/// Decides the playback position when starting a server-streamed session.
/// The device's local session may hold a newer position that failed to sync;
/// prefer it so locally-tracked progress is never lost to a stale server.
enum ProgressRestoreResolver {
    static func resolveCurrentTime(serverCurrentTime: Double, localCurrentTime: Double?, localDuration: Double?) -> Double {
        guard let localCurrentTime = localCurrentTime else { return serverCurrentTime }
        // A local position at/past the end means the item was finished locally; trust the server (e.g. a re-listen from 0)
        if let localDuration = localDuration, localDuration > 0, localCurrentTime >= localDuration { return serverCurrentTime }
        return max(serverCurrentTime, localCurrentTime)
    }
}
