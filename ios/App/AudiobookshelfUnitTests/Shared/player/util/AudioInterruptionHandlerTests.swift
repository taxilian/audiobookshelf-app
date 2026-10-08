//
//  AudioInterruptionHandlerTests.swift
//  AudiobookshelfUnitTests
//

import XCTest
@testable import Audiobookshelf

final class AudioInterruptionHandlerTests: XCTestCase {

    func testInterruptionWhilePlayingResumesWithoutShouldResume() {
        var handler = AudioInterruptionHandler()

        XCTAssertEqual(handler.handleInterruptionBegan(isPlaying: true, isAppSuspended: false), .pause)
        XCTAssertTrue(handler.wasPlayingBeforeInterruption)

        // After a phone call or alarm iOS usually does not set .shouldResume,
        // but playback that was interrupted should still resume
        XCTAssertEqual(handler.handleInterruptionEnded(shouldResume: false, isAppSuspended: false), .resume)
    }

    func testInterruptionWhilePlayingResumesWithShouldResume() {
        var handler = AudioInterruptionHandler()

        XCTAssertEqual(handler.handleInterruptionBegan(isPlaying: true, isAppSuspended: false), .pause)
        XCTAssertEqual(handler.handleInterruptionEnded(shouldResume: true, isAppSuspended: false), .resume)
    }

    func testInterruptionWhilePausedPausesButDoesNotResume() {
        var handler = AudioInterruptionHandler()

        XCTAssertEqual(handler.handleInterruptionBegan(isPlaying: false, isAppSuspended: false), .pause)
        XCTAssertFalse(handler.wasPlayingBeforeInterruption)
        XCTAssertEqual(handler.handleInterruptionEnded(shouldResume: false, isAppSuspended: false), .none)
    }

    func testEndedWithShouldResumeResumesWhenNeverInterruptedWhilePlaying() {
        var handler = AudioInterruptionHandler()

        XCTAssertEqual(handler.handleInterruptionEnded(shouldResume: true, isAppSuspended: false), .resume)
    }

    func testInterruptionFromAppSuspendDoesNotPauseOrResume() {
        var handler = AudioInterruptionHandler()

        XCTAssertEqual(handler.handleInterruptionBegan(isPlaying: true, isAppSuspended: true), .none)
        XCTAssertFalse(handler.wasPlayingBeforeInterruption)
        XCTAssertEqual(handler.handleInterruptionEnded(shouldResume: false, isAppSuspended: false), .none)
    }

    func testEndedWhileAppSuspendedDoesNotResumeAndResetsFlag() {
        var handler = AudioInterruptionHandler()

        XCTAssertEqual(handler.handleInterruptionBegan(isPlaying: true, isAppSuspended: false), .pause)
        XCTAssertEqual(handler.handleInterruptionEnded(shouldResume: false, isAppSuspended: true), .none)
        XCTAssertFalse(handler.wasPlayingBeforeInterruption)
    }

    func testWasPlayingFlagResetsAfterEnded() {
        var handler = AudioInterruptionHandler()

        XCTAssertEqual(handler.handleInterruptionBegan(isPlaying: true, isAppSuspended: false), .pause)
        XCTAssertEqual(handler.handleInterruptionEnded(shouldResume: false, isAppSuspended: false), .resume)
        XCTAssertFalse(handler.wasPlayingBeforeInterruption)

        // A second ended (e.g. duplicate notification) must not resume again
        XCTAssertEqual(handler.handleInterruptionEnded(shouldResume: false, isAppSuspended: false), .none)
    }
}
