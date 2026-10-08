//
//  NowPlayingInfoTests.swift
//  AudiobookshelfUnitTests
//
//  Created by Sisyphus on 10/07/26.
//

import XCTest
import MediaPlayer
@testable import Audiobookshelf

final class NowPlayingInfoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        NowPlayingInfo.shared.reset()
        waitForMainQueue()
    }
    
    override func tearDown() {
        NowPlayingInfo.shared.reset()
        waitForMainQueue()
        super.tearDown()
    }
    
    func testSetSessionMetadataPublishesNowPlayingInfoImmediately() {
        let metadata = NowPlayingMetadata(id: "test-id-1", itemId: "item-1", title: "Test Book", author: "Test Author", series: nil, isLocal: false)
        
        NowPlayingInfo.shared.setSessionMetadata(metadata: metadata)
        
        waitForMainQueue()
        
        let published = MPNowPlayingInfoCenter.default().nowPlayingInfo
        XCTAssertEqual(published?[MPMediaItemPropertyTitle] as? String, "Test Book")
        XCTAssertEqual(published?[MPMediaItemPropertyArtist] as? String, "Test Author")
    }
    
    func testResetClearsPublishedNowPlayingInfo() {
        let metadata = NowPlayingMetadata(id: "test-id-2", itemId: "item-2", title: "Another Book", author: "Another Author", series: nil, isLocal: false)
        NowPlayingInfo.shared.setSessionMetadata(metadata: metadata)
        waitForMainQueue()
        
        NowPlayingInfo.shared.reset()
        waitForMainQueue()
        
        XCTAssertNil(MPNowPlayingInfoCenter.default().nowPlayingInfo)
    }
    
    private func waitForMainQueue() {
        let expectation = expectation(description: "Main queue drained")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
}
