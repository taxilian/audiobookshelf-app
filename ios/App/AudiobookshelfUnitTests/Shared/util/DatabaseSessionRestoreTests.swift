//
//  DatabaseSessionRestoreTests.swift
//  AudiobookshelfUnitTests
//

import XCTest
import RealmSwift
@testable import Audiobookshelf

final class DatabaseSessionRestoreTests: XCTestCase {
    private var originalRealmConfiguration: Realm.Configuration!

    override func setUp() {
        super.setUp()
        // Point the default Realm at an in-memory instance BEFORE any Realm access in the test
        originalRealmConfiguration = Realm.Configuration.defaultConfiguration
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.inMemoryIdentifier = "DatabaseSessionRestoreTests"
        Realm.Configuration.defaultConfiguration = configuration
    }

    override func tearDown() {
        if let realm = try? Realm() {
            try? realm.write {
                realm.deleteAll()
            }
        }
        Realm.Configuration.defaultConfiguration = originalRealmConfiguration
        super.tearDown()
    }

    func testReturnsMostRecentActiveSessionIgnoringNewerInactiveSessions() throws {
        let realm = try Realm()

        let olderActive = PlaybackSession()
        olderActive.id = "session-older-active"
        olderActive.libraryItemId = "item-1"
        olderActive.isActiveSession = true
        olderActive.updatedAt = 1000

        let newerActive = PlaybackSession()
        newerActive.id = "session-newer-active"
        newerActive.libraryItemId = "item-2"
        newerActive.isActiveSession = true
        newerActive.updatedAt = 2000

        let newestInactive = PlaybackSession()
        newestInactive.id = "session-newest-inactive"
        newestInactive.libraryItemId = "item-3"
        newestInactive.isActiveSession = false
        newestInactive.updatedAt = 3000

        try realm.write {
            realm.add([olderActive, newerActive, newestInactive])
        }

        let restored = Database.shared.getLastActivePlaybackSession()
        XCTAssertEqual(restored?.id, "session-newer-active")
        XCTAssertEqual(restored?.libraryItemId, "item-2")
    }

    func testReturnsNilWhenNoActiveSessions() throws {
        let realm = try Realm()

        let inactive = PlaybackSession()
        inactive.id = "session-inactive"
        inactive.libraryItemId = "item-1"
        inactive.isActiveSession = false
        inactive.updatedAt = 3000

        try realm.write {
            realm.add(inactive)
        }

        XCTAssertNil(Database.shared.getLastActivePlaybackSession())
    }
}
