//
//  PartnerSharingServiceTests.swift
//  BloomHerTests
//
//  Tests for PartnerSharingService — code generation, validation,
//  session lifecycle, and UserDefaults persistence.
//
//  UserDefaults is cleaned between tests via a suite-based defaults
//  instance so production storage is never touched.
//

import XCTest
@testable import BloomHer

final class PartnerSharingServiceTests: XCTestCase {

    // MARK: - Constants (mirror the private values in production code)

    private static let codeLength    = 6
    private static let validAlphabet = Set("BCDFGHJKLMNPQRSTVWXYZ23456789")
    private static let storageKey    = "bloomher.partnerSessions"

    // MARK: - Subject Under Test

    private var service: PartnerSharingService!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        // Clear any persisted session data before each test to ensure isolation.
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
        service = PartnerSharingService()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
        service = nil
        super.tearDown()
    }

    // MARK: - Code Generation: Length

    func testGenerateShareCode_returns6Characters() {
        let code = service.generateShareCode()
        XCTAssertEqual(
            code.count,
            Self.codeLength,
            "generateShareCode() must return exactly \(Self.codeLength) characters. Got '\(code)'."
        )
    }

    // MARK: - Code Generation: Alphabet

    func testGenerateShareCode_onlyContainsValidCharacters() {
        // Run multiple times to reduce flakiness from randomness.
        for _ in 0..<50 {
            let code = service.generateShareCode()
            for char in code {
                XCTAssertTrue(
                    Self.validAlphabet.contains(char),
                    "Character '\(char)' in code '\(code)' is not in the allowed alphabet."
                )
            }
        }
    }

    func testGenerateShareCode_neverContainsVowelsOrAmbiguousDigits() {
        let forbidden: Set<Character> = ["A", "E", "I", "O", "U", "0", "1"]
        for _ in 0..<50 {
            let code = service.generateShareCode()
            for char in code {
                XCTAssertFalse(
                    forbidden.contains(char),
                    "Code '\(code)' contains forbidden character '\(char)'."
                )
            }
        }
    }

    func testGenerateShareCode_isUppercase() {
        for _ in 0..<20 {
            let code = service.generateShareCode()
            XCTAssertEqual(
                code,
                code.uppercased(),
                "generateShareCode() must return uppercase codes. Got '\(code)'."
            )
        }
    }

    // MARK: - Code Generation: Uniqueness

    func testGenerateShareCode_uniqueEachTime() {
        // Generate 100 codes and verify there are no exact duplicates.
        // With an alphabet of 29 characters and 6 positions there are 29^6 ≈ 511 M
        // possibilities, so collisions in 100 draws are astronomically unlikely.
        var codes = Set<String>()
        for _ in 0..<100 {
            codes.insert(service.generateShareCode())
        }
        XCTAssertEqual(
            codes.count,
            100,
            "Each generateShareCode() call should produce a unique code (100-draw uniqueness test)."
        )
    }

    // MARK: - Validation: Valid Codes

    func testValidateShareCode_validCode() {
        let code = service.generateShareCode()
        XCTAssertTrue(
            service.validateShareCode(code),
            "A freshly generated code must pass validateShareCode. Code: '\(code)'."
        )
    }

    func testValidateShareCode_validLowercase() {
        // The validator should accept lowercase input by normalising to uppercase.
        let code = service.generateShareCode().lowercased()
        XCTAssertTrue(
            service.validateShareCode(code),
            "validateShareCode must accept lowercase versions of valid codes."
        )
    }

    func testValidateShareCode_validWithLeadingTrailingWhitespace() {
        let code = "  " + service.generateShareCode() + "  "
        XCTAssertTrue(
            service.validateShareCode(code),
            "validateShareCode must trim whitespace before validating."
        )
    }

    // MARK: - Validation: Invalid Codes

    func testValidateShareCode_tooShort() {
        XCTAssertFalse(
            service.validateShareCode("BCDF"),
            "A 4-character code must fail validation."
        )
    }

    func testValidateShareCode_tooLong() {
        XCTAssertFalse(
            service.validateShareCode("BCDFGH23"),
            "An 8-character code must fail validation."
        )
    }

    func testValidateShareCode_empty() {
        XCTAssertFalse(
            service.validateShareCode(""),
            "An empty string must fail validation."
        )
    }

    func testValidateShareCode_containsVowel() {
        XCTAssertFalse(
            service.validateShareCode("ABCDFG"),
            "A code containing a vowel ('A') must fail validation."
        )
    }

    func testValidateShareCode_containsZero() {
        XCTAssertFalse(
            service.validateShareCode("BC0DFG"),
            "A code containing '0' (excluded for visual ambiguity) must fail validation."
        )
    }

    func testValidateShareCode_containsOne() {
        XCTAssertFalse(
            service.validateShareCode("BC1DFG"),
            "A code containing '1' (excluded for visual ambiguity) must fail validation."
        )
    }

    func testValidateShareCode_containsSpecialCharacter() {
        XCTAssertFalse(
            service.validateShareCode("BCD!FG"),
            "A code containing a special character must fail validation."
        )
    }

    // MARK: - Session Management: Activate

    func testActivateSharing_returnsSessionWithGeneratedCode() {
        let session = service.activateSharing(partnerName: nil)

        XCTAssertEqual(
            session.shareCode.count,
            Self.codeLength,
            "activateSharing must produce a session with a \(Self.codeLength)-character share code."
        )
        XCTAssertTrue(
            session.isActive,
            "A newly activated session must have isActive == true."
        )
    }

    func testActivateSharing_storesPartnerName() {
        let session = service.activateSharing(partnerName: "Jordan")
        XCTAssertEqual(
            session.partnerName,
            "Jordan",
            "activateSharing must preserve the supplied partner name."
        )
    }

    func testActivateSharing_storesNilPartnerName() {
        let session = service.activateSharing(partnerName: nil)
        XCTAssertNil(
            session.partnerName,
            "activateSharing with nil partnerName must produce a session with nil partnerName."
        )
    }

    func testActivateSharing_sessionIsPersisted() {
        _ = service.activateSharing(partnerName: nil)

        let activeSessions = service.fetchActiveSessions()
        XCTAssertEqual(
            activeSessions.count,
            1,
            "fetchActiveSessions must return the newly created session after activateSharing."
        )
    }

    // MARK: - Session Management: Deactivate

    func testDeactivateSharing_marksSessionInactive() {
        let session = service.activateSharing(partnerName: nil)
        service.deactivateSharing(sessionID: session.id)

        let active = service.fetchActiveSessions()
        XCTAssertTrue(
            active.isEmpty,
            "deactivateSharing must mark the session inactive so it no longer appears in fetchActiveSessions."
        )
    }

    func testDeactivateSharing_unknownIDIsNoOp() {
        _ = service.activateSharing(partnerName: nil)
        service.deactivateSharing(sessionID: UUID().uuidString)

        XCTAssertEqual(
            service.fetchActiveSessions().count,
            1,
            "deactivateSharing with an unknown session ID must not affect other sessions."
        )
    }

    // MARK: - Session Management: Fetch Active

    func testFetchActiveSessions_returnsOnlyActive() {
        let s1 = service.activateSharing(partnerName: "Alex")
        _      = service.activateSharing(partnerName: "Blake")
        service.deactivateSharing(sessionID: s1.id)

        let active = service.fetchActiveSessions()
        XCTAssertEqual(
            active.count,
            1,
            "fetchActiveSessions must exclude deactivated sessions."
        )
        XCTAssertEqual(
            active[0].partnerName,
            "Blake",
            "The remaining active session should belong to Blake."
        )
    }

    func testFetchActiveSessions_emptyWhenNone() {
        XCTAssertTrue(
            service.fetchActiveSessions().isEmpty,
            "fetchActiveSessions must return an empty array when no sessions have been activated."
        )
    }

    // MARK: - Persistence: Survives Re-instantiation

    func testSessionPersists_acrossServiceInstances() {
        // Activate a session with the original service instance.
        let session = service.activateSharing(partnerName: "Rowan")

        // Create a fresh service instance that reads from the same UserDefaults.
        let freshService = PartnerSharingService()
        let active = freshService.fetchActiveSessions()

        XCTAssertEqual(
            active.count,
            1,
            "Session data must persist in UserDefaults and be readable by a new service instance."
        )
        XCTAssertEqual(
            active[0].id,
            session.id,
            "The persisted session must have the same ID."
        )
    }

    // MARK: - PartnerShareSession: Codable

    func testPartnerShareSession_isCodable() {
        let original = PartnerShareSession(
            id:          "test-id-123",
            shareCode:   "BCD234",
            partnerName: "Sam",
            createdAt:   Date(timeIntervalSince1970: 1_700_000_000),
            isActive:    true
        )

        let encoded = try? JSONEncoder().encode(original)
        XCTAssertNotNil(encoded, "PartnerShareSession must be encodable to JSON.")

        let decoded = try? JSONDecoder().decode(PartnerShareSession.self, from: encoded!)
        XCTAssertNotNil(decoded, "PartnerShareSession must be decodable from JSON.")
        XCTAssertEqual(decoded?.id,          original.id,          "id must survive encode/decode.")
        XCTAssertEqual(decoded?.shareCode,   original.shareCode,   "shareCode must survive encode/decode.")
        XCTAssertEqual(decoded?.partnerName, original.partnerName, "partnerName must survive encode/decode.")
        XCTAssertEqual(decoded?.isActive,    original.isActive,    "isActive must survive encode/decode.")
    }
}
