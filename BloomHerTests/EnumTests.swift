//
//  EnumTests.swift
//  BloomHerTests
//
//  Sanity-checks for all domain enums in BloomHer.
//  Verifies display names, icons, Codable conformance, and CaseIterable coverage
//  to catch regressions when new cases are added.
//

import XCTest
@testable import BloomHer

final class EnumTests: XCTestCase {

    // MARK: - CyclePhase

    func testCyclePhaseDisplayNames() {
        let expectations: [CyclePhase: String] = [
            .menstrual:  "Menstrual",
            .follicular: "Follicular",
            .ovulation:  "Ovulation",
            .luteal:     "Luteal"
        ]
        for (phase, expected) in expectations {
            XCTAssertEqual(
                phase.displayName,
                expected,
                "CyclePhase.\(phase) displayName should be '\(expected)'."
            )
        }
    }

    func testCyclePhaseIcons() {
        // Every phase must return a non-empty SF Symbol name.
        for phase in CyclePhase.allCases {
            XCTAssertFalse(
                phase.icon.isEmpty,
                "CyclePhase.\(phase) must have a non-empty icon string."
            )
        }
        // Spot-check specific symbols.
        XCTAssertEqual(CyclePhase.menstrual.icon,  "drop.fill",   "Menstrual phase icon mismatch.")
        XCTAssertEqual(CyclePhase.follicular.icon, "leaf.fill",   "Follicular phase icon mismatch.")
        XCTAssertEqual(CyclePhase.ovulation.icon,  "circle.fill", "Ovulation phase icon mismatch.")
        XCTAssertEqual(CyclePhase.luteal.icon,     "moon.fill",   "Luteal phase icon mismatch.")
    }

    func testCyclePhaseColors() {
        // All phases must return a Color value; we assert it is not nil
        // by simply accessing the property (SwiftUI Color never throws).
        for phase in CyclePhase.allCases {
            let color = phase.color
            // If this compiles and runs without crashing, the Color init succeeded.
            _ = color
            XCTAssertNotNil(
                phase.color,
                "CyclePhase.\(phase) must return a non-nil Color."
            )
        }
    }

    func testCyclePhaseEmojis() {
        // Each phase must have a non-empty emoji character.
        for phase in CyclePhase.allCases {
            XCTAssertFalse(
                phase.emoji.isEmpty,
                "CyclePhase.\(phase) must have a non-empty emoji."
            )
        }
    }

    func testCyclePhaseDescriptions() {
        // Each phase must have a non-empty description.
        for phase in CyclePhase.allCases {
            XCTAssertFalse(
                phase.description.isEmpty,
                "CyclePhase.\(phase) must have a non-empty description."
            )
        }
    }

    func testCyclePhaseAllCasesCount() {
        XCTAssertEqual(
            CyclePhase.allCases.count,
            4,
            "CyclePhase must have exactly 4 cases: menstrual, follicular, ovulation, luteal."
        )
    }

    func testCyclePhaseCodable() {
        for phase in CyclePhase.allCases {
            roundtripCodable(phase, label: "CyclePhase.\(phase)")
        }
    }

    // MARK: - Mood

    func testMoodDisplayNames() {
        let expectations: [Mood: String] = [
            .happy:      "Happy",
            .calm:       "Calm",
            .anxious:    "Anxious",
            .irritable:  "Irritable",
            .sad:        "Sad",
            .angry:      "Angry",
            .moodSwings: "Mood Swings",
            .crying:     "Crying",
            .energetic:  "Energetic",
            .tired:      "Tired"
        ]
        for (mood, expected) in expectations {
            XCTAssertEqual(
                mood.displayName,
                expected,
                "Mood.\(mood) displayName should be '\(expected)'."
            )
        }
    }

    func testMoodEmojis() {
        // Each mood must return a non-empty emoji string.
        for mood in Mood.allCases {
            XCTAssertFalse(
                mood.emoji.isEmpty,
                "Mood.\(mood) must have a non-empty emoji."
            )
        }
        // Spot-check a few.
        XCTAssertEqual(Mood.happy.emoji, "😊", "Mood.happy emoji mismatch.")
        XCTAssertEqual(Mood.sad.emoji,   "😢", "Mood.sad emoji mismatch.")
        XCTAssertEqual(Mood.tired.emoji, "😴", "Mood.tired emoji mismatch.")
    }

    func testMoodIcons() {
        for mood in Mood.allCases {
            XCTAssertFalse(
                mood.icon.isEmpty,
                "Mood.\(mood) must have a non-empty icon (SF Symbol name)."
            )
        }
    }

    func testMoodAllCasesCount() {
        XCTAssertEqual(
            Mood.allCases.count,
            10,
            "Mood must have exactly 10 cases."
        )
    }

    func testMoodCodable() {
        for mood in Mood.allCases {
            roundtripCodable(mood, label: "Mood.\(mood)")
        }
    }

    // MARK: - Symptom

    func testSymptomDisplayNames() {
        let expectations: [Symptom: String] = [
            .headache:         "Headache",
            .backPain:         "Back Pain",
            .breastTenderness: "Breast Tenderness",
            .bloating:         "Bloating",
            .jointPain:        "Joint Pain",
            .pelvicPain:       "Pelvic Pain",
            .nausea:           "Nausea",
            .diarrhoea:        "Diarrhoea",
            .constipation:     "Constipation",
            .acne:             "Acne",
            .insomnia:         "Insomnia",
            .hotFlush:         "Hot Flush",
            .dizziness:        "Dizziness"
        ]
        for (symptom, expected) in expectations {
            XCTAssertEqual(
                symptom.displayName,
                expected,
                "Symptom.\(symptom) displayName should be '\(expected)'."
            )
        }
    }

    func testSymptomIcons() {
        for symptom in Symptom.allCases {
            XCTAssertFalse(
                symptom.icon.isEmpty,
                "Symptom.\(symptom) must have a non-empty icon (SF Symbol name)."
            )
        }
    }

    func testSymptomAllCasesCount() {
        XCTAssertEqual(
            Symptom.allCases.count,
            13,
            "Symptom must have exactly 13 cases."
        )
    }

    func testSymptomCodable() {
        for symptom in Symptom.allCases {
            roundtripCodable(symptom, label: "Symptom.\(symptom)")
        }
    }

    // MARK: - FlowLevel

    func testFlowLevelCaseIterable() {
        // FlowLevel must conform to CaseIterable and expose all 5 intensities.
        XCTAssertEqual(
            FlowLevel.allCases.count,
            5,
            "FlowLevel must have 5 cases: spotting, light, medium, heavy, veryHeavy."
        )
        let expectedCases: [FlowLevel] = [.spotting, .light, .medium, .heavy, .veryHeavy]
        for expected in expectedCases {
            XCTAssertTrue(
                FlowLevel.allCases.contains(expected),
                "FlowLevel.allCases must contain .\(expected)."
            )
        }
    }

    func testFlowLevelDisplayNames() {
        let expectations: [FlowLevel: String] = [
            .spotting:  "Spotting",
            .light:     "Light",
            .medium:    "Medium",
            .heavy:     "Heavy",
            .veryHeavy: "Very Heavy"
        ]
        for (level, expected) in expectations {
            XCTAssertEqual(
                level.displayName,
                expected,
                "FlowLevel.\(level) displayName should be '\(expected)'."
            )
        }
    }

    func testFlowLevelDotCounts() {
        // Dot counts must increase monotonically from spotting (1) to veryHeavy (5).
        XCTAssertEqual(FlowLevel.spotting.dotCount,  1, "spotting must have dotCount 1.")
        XCTAssertEqual(FlowLevel.light.dotCount,     2, "light must have dotCount 2.")
        XCTAssertEqual(FlowLevel.medium.dotCount,    3, "medium must have dotCount 3.")
        XCTAssertEqual(FlowLevel.heavy.dotCount,     4, "heavy must have dotCount 4.")
        XCTAssertEqual(FlowLevel.veryHeavy.dotCount, 5, "veryHeavy must have dotCount 5.")
    }

    func testFlowLevelCodable() {
        for level in FlowLevel.allCases {
            roundtripCodable(level, label: "FlowLevel.\(level)")
        }
    }

    // MARK: - PredictionConfidence

    func testPredictionConfidenceDisplayNames() {
        XCTAssertEqual(PredictionConfidence.low.displayName,    "Low",    "low displayName mismatch.")
        XCTAssertEqual(PredictionConfidence.medium.displayName, "Medium", "medium displayName mismatch.")
        XCTAssertEqual(PredictionConfidence.high.displayName,   "High",   "high displayName mismatch.")
    }

    func testPredictionConfidenceCodable() {
        for confidence in [PredictionConfidence.low, .medium, .high] {
            roundtripCodable(confidence, label: "PredictionConfidence.\(confidence)")
        }
    }

    // MARK: - All Enums Conform to Codable (Compile-Time)

    func testAllEnumsConformToCodable() {
        // These assertions are essentially compile-time proof that each enum
        // can be encoded and decoded. If the conformances were removed, the
        // `roundtripCodable` call would fail to compile.
        roundtripCodable(CyclePhase.menstrual,          label: "CyclePhase")
        roundtripCodable(Mood.happy,                    label: "Mood")
        roundtripCodable(Symptom.headache,              label: "Symptom")
        roundtripCodable(FlowLevel.medium,              label: "FlowLevel")
        roundtripCodable(PredictionConfidence.medium,   label: "PredictionConfidence")
    }

    // MARK: - Private Helpers

    /// Encodes `value` to JSON then decodes it back, asserting the round-trip succeeds
    /// and the decoded value equals the original.
    private func roundtripCodable<T: Codable & Equatable>(_ value: T, label: String) {
        guard let encoded = try? JSONEncoder().encode(value) else {
            XCTFail("\(label) failed to encode.")
            return
        }
        guard let decoded = try? JSONDecoder().decode(T.self, from: encoded) else {
            XCTFail("\(label) failed to decode.")
            return
        }
        XCTAssertEqual(decoded, value, "\(label) must be equal after a JSON encode/decode round-trip.")
    }
}
