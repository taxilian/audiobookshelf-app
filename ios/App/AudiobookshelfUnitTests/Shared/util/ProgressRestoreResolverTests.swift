//
//  ProgressRestoreResolverTests.swift
//  AudiobookshelfUnitTests
//

import XCTest
@testable import Audiobookshelf

final class ProgressRestoreResolverTests: XCTestCase {

    func testPrefersLocalPositionWhenLocalIsAheadOfServer() {
        // The reported progress loss: 15-20 minutes of listening never reached the server,
        // so the fresh server session would resume behind the device's local session
        let resolved = ProgressRestoreResolver.resolveCurrentTime(serverCurrentTime: 1800, localCurrentTime: 2700, localDuration: 36000)
        XCTAssertEqual(resolved, 2700)
    }

    func testUsesServerPositionWhenLocalIsBehindServer() {
        let resolved = ProgressRestoreResolver.resolveCurrentTime(serverCurrentTime: 2700, localCurrentTime: 1800, localDuration: 36000)
        XCTAssertEqual(resolved, 2700)
    }

    func testUsesServerPositionWhenNoLocalSessionExists() {
        let resolved = ProgressRestoreResolver.resolveCurrentTime(serverCurrentTime: 1200, localCurrentTime: nil, localDuration: nil)
        XCTAssertEqual(resolved, 1200)
    }

    func testUsesServerPositionWhenItemWasFinishedLocally() {
        // Finished locally: trust the server, e.g. the user started a re-listen from 0
        let resolved = ProgressRestoreResolver.resolveCurrentTime(serverCurrentTime: 0, localCurrentTime: 36000, localDuration: 36000)
        XCTAssertEqual(resolved, 0)
    }

    func testUsesServerPositionWhenPositionsAreEqual() {
        let resolved = ProgressRestoreResolver.resolveCurrentTime(serverCurrentTime: 1500, localCurrentTime: 1500, localDuration: 36000)
        XCTAssertEqual(resolved, 1500)
    }
}
