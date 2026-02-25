import Foundation

// MARK: - AffirmationData

/// Static content store for all affirmations in the BloomHer app.
///
/// Affirmations are keyed by cycle phase, life context (pregnancy, TTC, postpartum),
/// and thematic category. Use the helper methods to retrieve contextually appropriate
/// content rather than filtering the `affirmations` array directly.
enum AffirmationData {

    // MARK: - Full Collection

    static let affirmations: [AffirmationContent] = buildAffirmations()

    private static func buildAffirmations() -> [AffirmationContent] {
        var items: [AffirmationContent] = []
        items.reserveCapacity(
            menstrualAffirmations.count
            + follicularAffirmations.count
            + ovulationAffirmations.count
            + lutealAffirmations.count
            + coreUniversalAffirmations.count
            + pregnancyAffirmations.count
            + ttcContentAffirmations.count
            + postpartumAffirmations.count
        )
        items.append(contentsOf: menstrualAffirmations)
        items.append(contentsOf: follicularAffirmations)
        items.append(contentsOf: ovulationAffirmations)
        items.append(contentsOf: lutealAffirmations)
        items.append(contentsOf: coreUniversalAffirmations)
        items.append(contentsOf: pregnancyAffirmations)
        items.append(contentsOf: ttcContentAffirmations)
        items.append(contentsOf: postpartumAffirmations)
        return items
    }

    // MARK: - Query Helpers

    /// All affirmations belonging to a specific thematic category.
    static func affirmations(for category: AffirmationCategory) -> [AffirmationContent] {
        affirmations.filter { $0.category == category }
    }

    /// All affirmations associated with a given cycle phase, including universal ones
    /// (where `phase == nil`).
    static func affirmations(for phase: CyclePhase) -> [AffirmationContent] {
        affirmations.filter { $0.phase == phase || $0.phase == nil }
    }

    /// A random affirmation for the given cycle phase.
    static func randomAffirmation(for phase: CyclePhase) -> AffirmationContent {
        let pool = affirmations(for: phase)
        return pool.randomElement() ?? affirmations[0]
    }

    /// A deterministic daily affirmation derived from the calendar date and phase,
    /// so the same affirmation is shown all day without storing state.
    static func dailyAffirmation(for date: Date, phase: CyclePhase) -> AffirmationContent {
        let pool = affirmations(for: phase)
        guard !pool.isEmpty else { return affirmations[0] }
        let daysSinceEpoch = Calendar.current.dateComponents(
            [.day],
            from: Date(timeIntervalSince1970: 0),
            to: date
        ).day ?? 0
        let index = abs(daysSinceEpoch) % pool.count
        return pool[index]
    }

    /// All universal affirmations (phase is nil).
    static var universalAffirmations: [AffirmationContent] {
        affirmations.filter { $0.phase == nil && !$0.isPregnancy && !$0.isTTC && !$0.isPostpartum }
    }

    /// All affirmations suitable for use during pregnancy.
    static var pregnancySafeAffirmations: [AffirmationContent] {
        affirmations.filter { $0.isPregnancy || $0.phase == nil }
    }

    /// All affirmations for those trying to conceive.
    static var ttcAffirmations: [AffirmationContent] {
        affirmations.filter { $0.isTTC }
    }

    /// All affirmations for the postpartum period.
    static var postpartumSafeAffirmations: [AffirmationContent] {
        affirmations.filter { $0.isPostpartum || $0.phase == nil }
    }

    // MARK: - Menstrual Phase (Days 1–5)
    // Theme: compassion, rest, honouring the body's wisdom.

    private static let menstrualAffirmations: [AffirmationContent] = [
        AffirmationContent(
            id: "men-001",
            text: "My body is wise; rest is productive.",
            phase: .menstrual,
            category: .rest
        ),
        AffirmationContent(
            id: "men-002",
            text: "I honour my need for quiet and care.",
            phase: .menstrual,
            category: .rest
        ),
        AffirmationContent(
            id: "men-003",
            text: "This slowdown is strength, not weakness.",
            phase: .menstrual,
            category: .strength
        ),
        AffirmationContent(
            id: "men-004",
            text: "I release what no longer serves me with grace.",
            phase: .menstrual,
            category: .growth
        ),
        AffirmationContent(
            id: "men-005",
            text: "My body knows exactly what it is doing.",
            phase: .menstrual,
            category: .body
        ),
        AffirmationContent(
            id: "men-006",
            text: "I am allowed to take up space and slow down.",
            phase: .menstrual,
            category: .rest
        ),
        AffirmationContent(
            id: "men-007",
            text: "Tenderness toward myself is always the right choice.",
            phase: .menstrual,
            category: .love
        ),
        AffirmationContent(
            id: "men-008",
            text: "Every cycle is a new beginning waiting in this ending.",
            phase: .menstrual,
            category: .growth
        ),
        AffirmationContent(
            id: "men-009",
            text: "I trust my body's natural rhythm.",
            phase: .menstrual,
            category: .body
        ),
        AffirmationContent(
            id: "men-010",
            text: "Nourishing myself today is an act of courage.",
            phase: .menstrual,
            category: .courage
        ),
        AffirmationContent(
            id: "men-011",
            text: "I am worthy of warmth, comfort, and care.",
            phase: .menstrual,
            category: .love
        ),
        AffirmationContent(
            id: "men-012",
            text: "My sensitivity is a superpower, not a flaw.",
            phase: .menstrual,
            category: .strength
        ),
        AffirmationContent(
            id: "men-013",
            text: "I permit myself to be still and at peace.",
            phase: .menstrual,
            category: .rest
        ),
        AffirmationContent(
            id: "men-014",
            text: "My needs are valid and worth meeting.",
            phase: .menstrual,
            category: .love
        ),
        AffirmationContent(
            id: "men-015",
            text: "I embrace the quiet power of turning inward.",
            phase: .menstrual,
            category: .rest
        ),
        AffirmationContent(
            id: "men-016",
            text: "Each breath I take renews and restores me.",
            phase: .menstrual,
            category: .body
        ),
        AffirmationContent(
            id: "men-017",
            text: "Resting is how I prepare for everything that comes next.",
            phase: .menstrual,
            category: .rest
        ),
        AffirmationContent(
            id: "men-018",
            text: "I release tension with every exhale.",
            phase: .menstrual,
            category: .rest
        ),
    ]

    // MARK: - Follicular Phase (Days 6–13)
    // Theme: growth, curiosity, fresh starts, rising energy.

    private static let follicularAffirmations: [AffirmationContent] = [
        AffirmationContent(
            id: "fol-001",
            text: "I am growing into my power.",
            phase: .follicular,
            category: .growth
        ),
        AffirmationContent(
            id: "fol-002",
            text: "New energy flows through me.",
            phase: .follicular,
            category: .body
        ),
        AffirmationContent(
            id: "fol-003",
            text: "I plant seeds of intention today.",
            phase: .follicular,
            category: .growth
        ),
        AffirmationContent(
            id: "fol-004",
            text: "Every day I learn and expand.",
            phase: .follicular,
            category: .growth
        ),
        AffirmationContent(
            id: "fol-005",
            text: "I am open to fresh possibilities.",
            phase: .follicular,
            category: .courage
        ),
        AffirmationContent(
            id: "fol-006",
            text: "My curiosity is a gift I give myself.",
            phase: .follicular,
            category: .growth
        ),
        AffirmationContent(
            id: "fol-007",
            text: "I step forward with confidence and grace.",
            phase: .follicular,
            category: .courage
        ),
        AffirmationContent(
            id: "fol-008",
            text: "Rising energy fuels my vision.",
            phase: .follicular,
            category: .strength
        ),
        AffirmationContent(
            id: "fol-009",
            text: "I welcome new beginnings with an open heart.",
            phase: .follicular,
            category: .love
        ),
        AffirmationContent(
            id: "fol-010",
            text: "I am ready to try, to explore, to become.",
            phase: .follicular,
            category: .growth
        ),
        AffirmationContent(
            id: "fol-011",
            text: "My goals are within reach.",
            phase: .follicular,
            category: .courage
        ),
        AffirmationContent(
            id: "fol-012",
            text: "I build momentum one intentional step at a time.",
            phase: .follicular,
            category: .strength
        ),
        AffirmationContent(
            id: "fol-013",
            text: "Possibility lives in every moment.",
            phase: .follicular,
            category: .growth
        ),
        AffirmationContent(
            id: "fol-014",
            text: "I nurture my dreams with daily action.",
            phase: .follicular,
            category: .growth
        ),
        AffirmationContent(
            id: "fol-015",
            text: "My mind is sharp, my spirit is bright.",
            phase: .follicular,
            category: .strength
        ),
        AffirmationContent(
            id: "fol-016",
            text: "I honour the spark inside me.",
            phase: .follicular,
            category: .love
        ),
        AffirmationContent(
            id: "fol-017",
            text: "Starting fresh is always available to me.",
            phase: .follicular,
            category: .courage
        ),
        AffirmationContent(
            id: "fol-018",
            text: "I trust the timing of my growth.",
            phase: .follicular,
            category: .growth
        ),
    ]

    // MARK: - Ovulation Phase (Days 14–17)
    // Theme: confidence, radiance, connection, expression.

    private static let ovulationAffirmations: [AffirmationContent] = [
        AffirmationContent(
            id: "ovu-001",
            text: "I radiate confidence and warmth.",
            phase: .ovulation,
            category: .courage
        ),
        AffirmationContent(
            id: "ovu-002",
            text: "My creativity is at its peak.",
            phase: .ovulation,
            category: .growth
        ),
        AffirmationContent(
            id: "ovu-003",
            text: "I embrace my fullest expression.",
            phase: .ovulation,
            category: .body
        ),
        AffirmationContent(
            id: "ovu-004",
            text: "I am magnetic, vibrant, and alive.",
            phase: .ovulation,
            category: .body
        ),
        AffirmationContent(
            id: "ovu-005",
            text: "My voice matters and deserves to be heard.",
            phase: .ovulation,
            category: .courage
        ),
        AffirmationContent(
            id: "ovu-006",
            text: "I show up fully for myself and others.",
            phase: .ovulation,
            category: .strength
        ),
        AffirmationContent(
            id: "ovu-007",
            text: "Abundance flows to and through me.",
            phase: .ovulation,
            category: .love
        ),
        AffirmationContent(
            id: "ovu-008",
            text: "I am exactly where I am meant to be.",
            phase: .ovulation,
            category: .general
        ),
        AffirmationContent(
            id: "ovu-009",
            text: "My light brightens every room I enter.",
            phase: .ovulation,
            category: .courage
        ),
        AffirmationContent(
            id: "ovu-010",
            text: "I give and receive love freely.",
            phase: .ovulation,
            category: .love
        ),
        AffirmationContent(
            id: "ovu-011",
            text: "I communicate with clarity and compassion.",
            phase: .ovulation,
            category: .strength
        ),
        AffirmationContent(
            id: "ovu-012",
            text: "Confidence is my natural state.",
            phase: .ovulation,
            category: .courage
        ),
        AffirmationContent(
            id: "ovu-013",
            text: "I am a creative force in my own life.",
            phase: .ovulation,
            category: .growth
        ),
        AffirmationContent(
            id: "ovu-014",
            text: "I attract meaningful connections.",
            phase: .ovulation,
            category: .love
        ),
        AffirmationContent(
            id: "ovu-015",
            text: "My energy inspires those around me.",
            phase: .ovulation,
            category: .strength
        ),
        AffirmationContent(
            id: "ovu-016",
            text: "I celebrate who I am becoming.",
            phase: .ovulation,
            category: .growth
        ),
        AffirmationContent(
            id: "ovu-017",
            text: "Joy is my birthright and I claim it today.",
            phase: .ovulation,
            category: .love
        ),
        AffirmationContent(
            id: "ovu-018",
            text: "I trust my instincts completely.",
            phase: .ovulation,
            category: .courage
        ),
    ]

    // MARK: - Luteal Phase (Days 18–28)
    // Theme: patience, self-care, emotional depth, winding down.

    private static let lutealAffirmations: [AffirmationContent] = [
        AffirmationContent(
            id: "lut-001",
            text: "I am patient with myself.",
            phase: .luteal,
            category: .rest
        ),
        AffirmationContent(
            id: "lut-002",
            text: "I trust the process of winding down.",
            phase: .luteal,
            category: .rest
        ),
        AffirmationContent(
            id: "lut-003",
            text: "Self-care is my priority.",
            phase: .luteal,
            category: .love
        ),
        AffirmationContent(
            id: "lut-004",
            text: "My emotions are information, not obstacles.",
            phase: .luteal,
            category: .body
        ),
        AffirmationContent(
            id: "lut-005",
            text: "I deserve gentleness, especially from myself.",
            phase: .luteal,
            category: .love
        ),
        AffirmationContent(
            id: "lut-006",
            text: "I set loving boundaries that protect my peace.",
            phase: .luteal,
            category: .strength
        ),
        AffirmationContent(
            id: "lut-007",
            text: "My inner world is rich and worthy of attention.",
            phase: .luteal,
            category: .rest
        ),
        AffirmationContent(
            id: "lut-008",
            text: "I am allowed to feel everything I feel.",
            phase: .luteal,
            category: .body
        ),
        AffirmationContent(
            id: "lut-009",
            text: "Slowing down helps me see what matters most.",
            phase: .luteal,
            category: .growth
        ),
        AffirmationContent(
            id: "lut-010",
            text: "I release what I cannot control.",
            phase: .luteal,
            category: .rest
        ),
        AffirmationContent(
            id: "lut-011",
            text: "My sensitivity makes me deeply human.",
            phase: .luteal,
            category: .body
        ),
        AffirmationContent(
            id: "lut-012",
            text: "I choose nourishment over perfection.",
            phase: .luteal,
            category: .love
        ),
        AffirmationContent(
            id: "lut-013",
            text: "Rest prepares me for my next chapter.",
            phase: .luteal,
            category: .rest
        ),
        AffirmationContent(
            id: "lut-014",
            text: "I am brave enough to ask for what I need.",
            phase: .luteal,
            category: .courage
        ),
        AffirmationContent(
            id: "lut-015",
            text: "Every mood passes; I remain.",
            phase: .luteal,
            category: .strength
        ),
        AffirmationContent(
            id: "lut-016",
            text: "I complete this cycle with gratitude.",
            phase: .luteal,
            category: .general
        ),
        AffirmationContent(
            id: "lut-017",
            text: "Comfort is not laziness — it is wisdom.",
            phase: .luteal,
            category: .rest
        ),
        AffirmationContent(
            id: "lut-018",
            text: "I honour my body's call to pause.",
            phase: .luteal,
            category: .body
        ),
    ]

    // MARK: - Universal (All Phases)
    // Theme: general wellbeing and self-compassion suitable for any day.

    private static let coreUniversalAffirmations: [AffirmationContent] = [
        AffirmationContent(
            id: "uni-001",
            text: "I am enough, exactly as I am.",
            category: .general
        ),
        AffirmationContent(
            id: "uni-002",
            text: "I choose kindness toward myself today.",
            category: .love
        ),
        AffirmationContent(
            id: "uni-003",
            text: "My body is my home and I care for it lovingly.",
            category: .body
        ),
        AffirmationContent(
            id: "uni-004",
            text: "I am resilient, adaptable, and capable.",
            category: .strength
        ),
        AffirmationContent(
            id: "uni-005",
            text: "Peace is something I can always return to.",
            category: .rest
        ),
        AffirmationContent(
            id: "uni-006",
            text: "I grow stronger with every experience.",
            category: .growth
        ),
        AffirmationContent(
            id: "uni-007",
            text: "I am deeply worthy of love and belonging.",
            category: .love
        ),
        AffirmationContent(
            id: "uni-008",
            text: "Every step forward, however small, counts.",
            category: .courage
        ),
        AffirmationContent(
            id: "uni-009",
            text: "I breathe in calm and breathe out tension.",
            category: .rest
        ),
        AffirmationContent(
            id: "uni-010",
            text: "My story is still being written.",
            category: .growth
        ),
        AffirmationContent(
            id: "uni-011",
            text: "Today I choose to be on my own side.",
            category: .love
        ),
        AffirmationContent(
            id: "uni-012",
            text: "I trust the wisdom within me.",
            category: .strength
        ),
        AffirmationContent(
            id: "uni-013",
            text: "Gratitude opens doors I did not even see.",
            category: .general
        ),
        AffirmationContent(
            id: "uni-014",
            text: "I deserve rest as much as I deserve success.",
            category: .rest
        ),
        AffirmationContent(
            id: "uni-015",
            text: "I am whole, complete, and worthy right now.",
            category: .body
        ),
    ]

    // MARK: - Pregnancy Affirmations

    private static let pregnancyAffirmations: [AffirmationContent] = [
        AffirmationContent(
            id: "prg-001",
            text: "My body knows how to grow and nurture life.",
            isPregnancy: true,
            category: .body
        ),
        AffirmationContent(
            id: "prg-002",
            text: "I trust my body through every stage of this journey.",
            isPregnancy: true,
            category: .strength
        ),
        AffirmationContent(
            id: "prg-003",
            text: "I am capable of more than I can imagine.",
            isPregnancy: true,
            category: .courage
        ),
        AffirmationContent(
            id: "prg-004",
            text: "I welcome every change with patience and wonder.",
            isPregnancy: true,
            category: .growth
        ),
        AffirmationContent(
            id: "prg-005",
            text: "My baby and I are safe, loved, and well.",
            isPregnancy: true,
            category: .love
        ),
        AffirmationContent(
            id: "prg-006",
            text: "I breathe in calm and send it to my baby.",
            isPregnancy: true,
            category: .rest
        ),
        AffirmationContent(
            id: "prg-007",
            text: "I am preparing a life full of love.",
            isPregnancy: true,
            category: .love
        ),
        AffirmationContent(
            id: "prg-008",
            text: "Every discomfort is temporary; this love is forever.",
            isPregnancy: true,
            category: .strength
        ),
        AffirmationContent(
            id: "prg-009",
            text: "I am growing stronger and wiser each day.",
            isPregnancy: true,
            category: .growth
        ),
        AffirmationContent(
            id: "prg-010",
            text: "I honour the miracle taking place within me.",
            isPregnancy: true,
            category: .body
        ),
        AffirmationContent(
            id: "prg-011",
            text: "I listen to my body and respond with care.",
            isPregnancy: true,
            category: .body
        ),
        AffirmationContent(
            id: "prg-012",
            text: "I am surrounded by love and support.",
            isPregnancy: true,
            category: .love
        ),
        AffirmationContent(
            id: "prg-013",
            text: "I release fear and embrace the beauty of becoming a mother.",
            isPregnancy: true,
            category: .courage
        ),
        AffirmationContent(
            id: "prg-014",
            text: "My intuition guides me toward what is best for my baby.",
            isPregnancy: true,
            category: .strength
        ),
        AffirmationContent(
            id: "prg-015",
            text: "I am exactly the mother my child needs.",
            isPregnancy: true,
            category: .love
        ),
    ]

    // MARK: - TTC (Trying to Conceive) Affirmations

    private static let ttcContentAffirmations: [AffirmationContent] = [
        AffirmationContent(
            id: "ttc-001",
            text: "My journey to motherhood is unfolding perfectly.",
            isTTC: true,
            category: .growth
        ),
        AffirmationContent(
            id: "ttc-002",
            text: "I release outcomes and trust the process.",
            isTTC: true,
            category: .rest
        ),
        AffirmationContent(
            id: "ttc-003",
            text: "Hope is a courageous act and I practice it daily.",
            isTTC: true,
            category: .courage
        ),
        AffirmationContent(
            id: "ttc-004",
            text: "My body is preparing for a beautiful future.",
            isTTC: true,
            category: .body
        ),
        AffirmationContent(
            id: "ttc-005",
            text: "I am patient, persistent, and full of love.",
            isTTC: true,
            category: .strength
        ),
        AffirmationContent(
            id: "ttc-006",
            text: "Every cycle teaches me something new.",
            isTTC: true,
            category: .growth
        ),
        AffirmationContent(
            id: "ttc-007",
            text: "I celebrate my body's strength and resilience.",
            isTTC: true,
            category: .strength
        ),
        AffirmationContent(
            id: "ttc-008",
            text: "I deserve joy, now and always.",
            isTTC: true,
            category: .love
        ),
        AffirmationContent(
            id: "ttc-009",
            text: "I am not alone on this path.",
            isTTC: true,
            category: .love
        ),
        AffirmationContent(
            id: "ttc-010",
            text: "My heart is open to the family I am building.",
            isTTC: true,
            category: .love
        ),
    ]

    // MARK: - Postpartum Affirmations

    private static let postpartumAffirmations: [AffirmationContent] = [
        AffirmationContent(
            id: "ppp-001",
            text: "I am doing an extraordinary thing every single day.",
            isPostpartum: true,
            category: .strength
        ),
        AffirmationContent(
            id: "ppp-002",
            text: "It is safe to ask for help.",
            isPostpartum: true,
            category: .courage
        ),
        AffirmationContent(
            id: "ppp-003",
            text: "My body carried, birthed, and now nourishes life — I am remarkable.",
            isPostpartum: true,
            category: .body
        ),
        AffirmationContent(
            id: "ppp-004",
            text: "I give myself grace as I learn.",
            isPostpartum: true,
            category: .love
        ),
        AffirmationContent(
            id: "ppp-005",
            text: "Rest is not a luxury — it is medicine.",
            isPostpartum: true,
            category: .rest
        ),
        AffirmationContent(
            id: "ppp-006",
            text: "I am healing, inside and out.",
            isPostpartum: true,
            category: .body
        ),
        AffirmationContent(
            id: "ppp-007",
            text: "My love for my baby is enough.",
            isPostpartum: true,
            category: .love
        ),
        AffirmationContent(
            id: "ppp-008",
            text: "Showing up imperfectly is still showing up.",
            isPostpartum: true,
            category: .strength
        ),
        AffirmationContent(
            id: "ppp-009",
            text: "I am rediscovering myself — and she is beautiful.",
            isPostpartum: true,
            category: .growth
        ),
        AffirmationContent(
            id: "ppp-010",
            text: "I honour every emotion that moves through me.",
            isPostpartum: true,
            category: .body
        ),
    ]
}
