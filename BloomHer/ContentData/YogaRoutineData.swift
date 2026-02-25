import Foundation

// MARK: - YogaRoutineData

/// A static library of curated yoga routines used across BloomHer's yoga features.
///
/// Routine IDs use kebab-case and must remain stable after shipping, as they
/// may be stored inside persisted `YogaSession` records.  The `poses` array
/// references pose IDs defined in `YogaPoseData` — any change to those IDs
/// must be reflected here simultaneously.
enum YogaRoutineData {

    // MARK: - Public Interface

    /// The complete routine library.
    static let routines: [YogaRoutine] = morning + evening + cyclePhase + prenatal + postnatal + emotional

    /// Returns all routines whose `category` matches the given value.
    static func routines(for category: ExerciseCategory) -> [YogaRoutine] {
        routines.filter { $0.category == category }
    }

    /// Returns routines recommended for a given cycle phase.
    ///
    /// The mapping from `CyclePhase` to `ExerciseCategory` follows the
    /// reproductive-health alignment defined in the product specification:
    /// - `.menstrual`  → `.menstrualYoga`
    /// - `.follicular` → `.follicularEnergy`
    /// - `.ovulation`  → `.ovulationPower`
    /// - `.luteal`     → `.lutealWindDown`
    ///
    /// General-purpose categories (breathing, pelvic floor) are also surfaced
    /// regardless of phase.
    static func recommendedRoutines(for phase: CyclePhase) -> [YogaRoutine] {
        let phaseCategory: ExerciseCategory
        switch phase {
        case .menstrual:  phaseCategory = .menstrualYoga
        case .follicular: phaseCategory = .follicularEnergy
        case .ovulation:  phaseCategory = .ovulationPower
        case .luteal:     phaseCategory = .lutealWindDown
        }
        return routines.filter { $0.category == phaseCategory }
    }

    /// Returns routines that are considered safe for a given trimester.
    ///
    /// A routine is considered trimester-safe when every pose it references has
    /// a `SafetyLevel` of `.safe` or `.modified` for that trimester (not `.avoid`).
    /// The check delegates to `YogaPoseData` for the authoritative safety matrix.
    static func safeRoutines(trimester: Int) -> [YogaRoutine] {
        routines.filter { routine in
            routine.poses.allSatisfy { ref in
                guard let pose = YogaPoseData.pose(byId: ref.poseId) else { return false }
                return pose.isSafe(forTrimester: trimester) != .avoid
            }
        }
    }

    // MARK: - Morning Routines (3)

    private static let morning: [YogaRoutine] = [

        // 1. Morning Flow
        YogaRoutine(
            id: "morning-flow",
            name: "Morning Flow",
            category: .follicularEnergy,
            durationMinutes: 20,
            difficulty: .beginner,
            description: "A gentle-to-moderate morning sequence that progressively wakes the body, lubricates the joints, and sets a calm, focused intention for the day.",
            poses: [
                YogaPoseReference(poseId: "easy-pose",               holdDurationSeconds: 60,  notes: "Begin seated; set a morning intention"),
                YogaPoseReference(poseId: "cat-cow",                  holdDurationSeconds: 90,  notes: "10 slow rounds to mobilise the spine"),
                YogaPoseReference(poseId: "childs-pose",              holdDurationSeconds: 60),
                YogaPoseReference(poseId: "tabletop",                 holdDurationSeconds: 20,  notes: "Transition to standing"),
                YogaPoseReference(poseId: "mountain-pose",            holdDurationSeconds: 30),
                YogaPoseReference(poseId: "standing-forward-fold",    holdDurationSeconds: 40),
                YogaPoseReference(poseId: "warrior-i",                holdDurationSeconds: 45,  notes: "Right side"),
                YogaPoseReference(poseId: "warrior-i",                holdDurationSeconds: 45,  notes: "Left side"),
                YogaPoseReference(poseId: "warrior-ii",               holdDurationSeconds: 45,  notes: "Right side"),
                YogaPoseReference(poseId: "warrior-ii",               holdDurationSeconds: 45,  notes: "Left side"),
                YogaPoseReference(poseId: "triangle-pose",            holdDurationSeconds: 40,  notes: "Right side"),
                YogaPoseReference(poseId: "triangle-pose",            holdDurationSeconds: 40,  notes: "Left side"),
                YogaPoseReference(poseId: "standing-forward-fold",    holdDurationSeconds: 40,  notes: "Closing fold"),
                YogaPoseReference(poseId: "savasana",                 holdDurationSeconds: 120, notes: "Rest and integrate")
            ],
            safetyNotes: [
                "Move slowly for the first few minutes while the body is still stiff from sleep.",
                "Hydrate before practice if possible."
            ],
            contraindications: [
                "Recent injury — reduce intensity and skip Warrior series"
            ],
            isPremium: false
        ),

        // 2. Energising Start
        YogaRoutine(
            id: "energising-start",
            name: "Energising Start",
            category: .follicularEnergy,
            durationMinutes: 15,
            difficulty: .beginner,
            description: "A quick 15-minute sequence designed to boost circulation and uplift mood before a busy morning, without requiring a full mat session.",
            poses: [
                YogaPoseReference(poseId: "mountain-pose",         holdDurationSeconds: 30),
                YogaPoseReference(poseId: "chair-pose",            holdDurationSeconds: 30,  repetitions: 3, notes: "3 rounds of 30 seconds"),
                YogaPoseReference(poseId: "warrior-ii",            holdDurationSeconds: 40,  notes: "Right side"),
                YogaPoseReference(poseId: "extended-side-angle",   holdDurationSeconds: 40,  notes: "Right side"),
                YogaPoseReference(poseId: "warrior-ii",            holdDurationSeconds: 40,  notes: "Left side"),
                YogaPoseReference(poseId: "extended-side-angle",   holdDurationSeconds: 40,  notes: "Left side"),
                YogaPoseReference(poseId: "tree-pose",             holdDurationSeconds: 40,  notes: "Right side"),
                YogaPoseReference(poseId: "tree-pose",             holdDurationSeconds: 40,  notes: "Left side"),
                YogaPoseReference(poseId: "standing-forward-fold", holdDurationSeconds: 40),
                YogaPoseReference(poseId: "savasana",              holdDurationSeconds: 60)
            ],
            safetyNotes: [
                "If balance is challenging in Tree Pose, keep one hand on a wall.",
                "Breathe through the nose throughout to maintain a calm energy."
            ],
            contraindications: [
                "Knee pain — skip Chair Pose or reduce depth significantly"
            ],
            isPremium: false
        ),

        // 3. Sun Salutation Flow
        YogaRoutine(
            id: "sun-salutation-flow",
            name: "Sun Salutation Flow",
            category: .follicularEnergy,
            durationMinutes: 10,
            difficulty: .beginner,
            description: "A condensed sun-inspired standing sequence using the poses in this library, building heat and rhythm in under 10 minutes.",
            poses: [
                YogaPoseReference(poseId: "mountain-pose",         holdDurationSeconds: 30),
                YogaPoseReference(poseId: "chair-pose",            holdDurationSeconds: 30),
                YogaPoseReference(poseId: "standing-forward-fold", holdDurationSeconds: 30),
                YogaPoseReference(poseId: "warrior-i",             holdDurationSeconds: 30, notes: "Right side"),
                YogaPoseReference(poseId: "warrior-ii",            holdDurationSeconds: 30, notes: "Right side"),
                YogaPoseReference(poseId: "warrior-i",             holdDurationSeconds: 30, notes: "Left side"),
                YogaPoseReference(poseId: "warrior-ii",            holdDurationSeconds: 30, notes: "Left side"),
                YogaPoseReference(poseId: "standing-forward-fold", holdDurationSeconds: 30),
                YogaPoseReference(poseId: "mountain-pose",         holdDurationSeconds: 30),
                YogaPoseReference(poseId: "easy-pose",             holdDurationSeconds: 60, notes: "Closing breath and intention")
            ],
            safetyNotes: [
                "Keep the transitions slow and deliberate.",
                "This is a simplified adaptation; a traditional sun salutation includes Downward Dog, which is not in this library."
            ],
            contraindications: [
                "First trimester nausea — take this practice very gently or skip"
            ],
            isPremium: false
        )
    ]

    // MARK: - Evening / Wind-Down Routines (3)

    private static let evening: [YogaRoutine] = [

        // 4. Bedtime Relaxation
        YogaRoutine(
            id: "bedtime-relaxation",
            name: "Bedtime Relaxation",
            category: .lutealWindDown,
            durationMinutes: 15,
            difficulty: .beginner,
            description: "A fully floor-based, restorative sequence using long passive holds to activate the parasympathetic nervous system before sleep.",
            poses: [
                YogaPoseReference(poseId: "easy-pose",            holdDurationSeconds: 60,  notes: "Breathing and release of the day"),
                YogaPoseReference(poseId: "butterfly-pose",       holdDurationSeconds: 120, notes: "With gentle forward fold"),
                YogaPoseReference(poseId: "seated-forward-fold",  holdDurationSeconds: 90),
                YogaPoseReference(poseId: "reclined-butterfly",   holdDurationSeconds: 180, notes: "With blocks under the knees"),
                YogaPoseReference(poseId: "knees-to-chest",       holdDurationSeconds: 60),
                YogaPoseReference(poseId: "supine-spinal-twist",  holdDurationSeconds: 60,  notes: "Right side"),
                YogaPoseReference(poseId: "supine-spinal-twist",  holdDurationSeconds: 60,  notes: "Left side"),
                YogaPoseReference(poseId: "savasana",             holdDurationSeconds: 180, notes: "Let sleep find you")
            ],
            safetyNotes: [
                "Perform in a dimly lit room at a comfortable temperature.",
                "A bolster or pillow under the knees in Savasana reduces low back strain."
            ],
            contraindications: [
                "Pregnancy beyond 20 weeks — substitute Savasana with Side-Lying Savasana and skip Supine Twist"
            ],
            isPremium: false
        ),

        // 5. Evening Stretch
        YogaRoutine(
            id: "evening-stretch",
            name: "Evening Stretch",
            category: .lutealWindDown,
            durationMinutes: 20,
            difficulty: .beginner,
            description: "A balanced mix of standing and seated stretches to unwind muscle tension accumulated during the day and prepare the body for deep sleep.",
            poses: [
                YogaPoseReference(poseId: "mountain-pose",              holdDurationSeconds: 30,  notes: "Arrive and breathe"),
                YogaPoseReference(poseId: "standing-forward-fold",      holdDurationSeconds: 60,  notes: "Hold elbows; sway gently"),
                YogaPoseReference(poseId: "pyramid-pose",               holdDurationSeconds: 40,  notes: "Right side"),
                YogaPoseReference(poseId: "pyramid-pose",               holdDurationSeconds: 40,  notes: "Left side"),
                YogaPoseReference(poseId: "wide-legged-forward-fold",   holdDurationSeconds: 60),
                YogaPoseReference(poseId: "butterfly-pose",             holdDurationSeconds: 90),
                YogaPoseReference(poseId: "wide-angle-seated-forward-fold", holdDurationSeconds: 90),
                YogaPoseReference(poseId: "head-to-knee-pose",          holdDurationSeconds: 60,  notes: "Right side"),
                YogaPoseReference(poseId: "head-to-knee-pose",          holdDurationSeconds: 60,  notes: "Left side"),
                YogaPoseReference(poseId: "figure-four-stretch",        holdDurationSeconds: 75,  notes: "Right side"),
                YogaPoseReference(poseId: "figure-four-stretch",        holdDurationSeconds: 75,  notes: "Left side"),
                YogaPoseReference(poseId: "legs-up-the-wall",           holdDurationSeconds: 180),
                YogaPoseReference(poseId: "savasana",                   holdDurationSeconds: 120)
            ],
            safetyNotes: [
                "Use blocks and blankets generously for support.",
                "Avoid holding the breath — lengthen the exhale throughout."
            ],
            contraindications: [
                "Hamstring injuries — keep the knees soft in all forward folds"
            ],
            isPremium: false
        ),

        // 6. Sleep Prep Flow
        YogaRoutine(
            id: "sleep-prep-flow",
            name: "Sleep Prep Flow",
            category: .lutealWindDown,
            durationMinutes: 10,
            difficulty: .beginner,
            description: "A minimal 10-minute floor routine focused entirely on releasing the hips and lower back, designed to be done in bed if needed.",
            poses: [
                YogaPoseReference(poseId: "reclined-butterfly",  holdDurationSeconds: 120),
                YogaPoseReference(poseId: "knees-to-chest",      holdDurationSeconds: 60),
                YogaPoseReference(poseId: "figure-four-stretch", holdDurationSeconds: 60, notes: "Right side"),
                YogaPoseReference(poseId: "figure-four-stretch", holdDurationSeconds: 60, notes: "Left side"),
                YogaPoseReference(poseId: "happy-baby-pose",     holdDurationSeconds: 60),
                YogaPoseReference(poseId: "savasana",            holdDurationSeconds: 120, notes: "Transition directly to sleep if desired")
            ],
            safetyNotes: [
                "Can be performed on a firm mattress.",
                "Focus on the exhale — make it twice as long as the inhale to activate the relaxation response."
            ],
            contraindications: [
                "Pregnancy beyond 12 weeks — substitute Happy Baby and Knees-to-Chest with Supported Butterfly and Side-Lying Savasana"
            ],
            isPremium: false
        )
    ]

    // MARK: - Cycle-Phase Routines (7)

    private static let cyclePhase: [YogaRoutine] = [

        // 7. Gentle Period Relief (Menstrual)
        YogaRoutine(
            id: "gentle-period-relief",
            name: "Gentle Period Relief",
            category: .menstrualYoga,
            durationMinutes: 15,
            difficulty: .beginner,
            description: "A deeply nurturing sequence for days 1–3 of your period, using passive holds and supported poses to ease cramping, reduce inflammation, and restore comfort.",
            poses: [
                YogaPoseReference(poseId: "easy-pose",           holdDurationSeconds: 60,  notes: "Breathe into the lower belly"),
                YogaPoseReference(poseId: "supported-butterfly", holdDurationSeconds: 300, notes: "Use a bolster and blocks; longest hold of the practice"),
                YogaPoseReference(poseId: "butterfly-pose",      holdDurationSeconds: 120, notes: "Active seated version"),
                YogaPoseReference(poseId: "childs-pose",         holdDurationSeconds: 120, notes: "Wide-knee version"),
                YogaPoseReference(poseId: "supported-childs-pose", holdDurationSeconds: 180, notes: "With bolster"),
                YogaPoseReference(poseId: "reclined-butterfly",  holdDurationSeconds: 180, notes: "Optional blocks under knees"),
                YogaPoseReference(poseId: "savasana",            holdDurationSeconds: 180)
            ],
            safetyNotes: [
                "Honour your energy level — if any pose increases pain, come out and rest.",
                "Avoid inversions and deep twists during the menstrual phase.",
                "Warmth (hot water bottle or heated blanket) combined with this practice enhances comfort."
            ],
            contraindications: [
                "Endometriosis — consult a women's health physiotherapist before deep hip openers"
            ],
            isPremium: false
        ),

        // 8. Cramp-Ease Flow (Menstrual)
        YogaRoutine(
            id: "cramp-ease-flow",
            name: "Cramp-Ease Flow",
            category: .menstrualYoga,
            durationMinutes: 10,
            difficulty: .beginner,
            description: "A targeted 10-minute routine focusing on the lower back and hips to reduce uterine cramping through movement and breath.",
            poses: [
                YogaPoseReference(poseId: "cat-cow",              holdDurationSeconds: 90,  notes: "8–10 slow rounds"),
                YogaPoseReference(poseId: "childs-pose",          holdDurationSeconds: 90),
                YogaPoseReference(poseId: "puppy-pose",           holdDurationSeconds: 60),
                YogaPoseReference(poseId: "butterfly-pose",       holdDurationSeconds: 90),
                YogaPoseReference(poseId: "reclined-butterfly",   holdDurationSeconds: 120),
                YogaPoseReference(poseId: "savasana",             holdDurationSeconds: 120)
            ],
            safetyNotes: [
                "Keep all movements slow and pain-free.",
                "Diaphragmatic breathing into the belly while in Child's Pose directly reduces uterine tension."
            ],
            contraindications: [
                "Severe dysmenorrhoea — seek medical evaluation if pain is unmanageable"
            ],
            isPremium: false
        ),

        // 9. Energy Builder (Follicular)
        YogaRoutine(
            id: "energy-builder",
            name: "Energy Builder",
            category: .follicularEnergy,
            durationMinutes: 25,
            difficulty: .intermediate,
            description: "A progressive 25-minute standing and balance sequence that capitalises on rising oestrogen and energy levels in the follicular phase.",
            poses: [
                YogaPoseReference(poseId: "mountain-pose",           holdDurationSeconds: 30),
                YogaPoseReference(poseId: "chair-pose",              holdDurationSeconds: 30, repetitions: 3),
                YogaPoseReference(poseId: "warrior-i",               holdDurationSeconds: 45, notes: "Right side"),
                YogaPoseReference(poseId: "warrior-ii",              holdDurationSeconds: 45, notes: "Right side"),
                YogaPoseReference(poseId: "extended-side-angle",     holdDurationSeconds: 40, notes: "Right side"),
                YogaPoseReference(poseId: "triangle-pose",           holdDurationSeconds: 40, notes: "Right side"),
                YogaPoseReference(poseId: "warrior-i",               holdDurationSeconds: 45, notes: "Left side"),
                YogaPoseReference(poseId: "warrior-ii",              holdDurationSeconds: 45, notes: "Left side"),
                YogaPoseReference(poseId: "extended-side-angle",     holdDurationSeconds: 40, notes: "Left side"),
                YogaPoseReference(poseId: "triangle-pose",           holdDurationSeconds: 40, notes: "Left side"),
                YogaPoseReference(poseId: "tree-pose",               holdDurationSeconds: 40, notes: "Right side"),
                YogaPoseReference(poseId: "tree-pose",               holdDurationSeconds: 40, notes: "Left side"),
                YogaPoseReference(poseId: "wide-legged-forward-fold", holdDurationSeconds: 60),
                YogaPoseReference(poseId: "butterfly-pose",          holdDurationSeconds: 60),
                YogaPoseReference(poseId: "savasana",                holdDurationSeconds: 120)
            ],
            safetyNotes: [
                "Take a moment between each standing pose to ground in Mountain Pose.",
                "Stay hydrated — this is a warming practice."
            ],
            contraindications: [
                "Active menstrual cramping — use Gentle Period Relief instead",
                "Joint hypermobility — avoid locking knees in standing poses"
            ],
            isPremium: false
        ),

        // 10. Power Flow (Follicular)
        YogaRoutine(
            id: "power-flow",
            name: "Power Flow",
            category: .follicularEnergy,
            durationMinutes: 30,
            difficulty: .intermediate,
            description: "The most dynamic routine in the library, using balance poses and strength-building sequences to match peak follicular-phase vitality.",
            poses: [
                YogaPoseReference(poseId: "mountain-pose",            holdDurationSeconds: 30),
                YogaPoseReference(poseId: "chair-pose",               holdDurationSeconds: 45, repetitions: 3),
                YogaPoseReference(poseId: "warrior-i",                holdDurationSeconds: 45, notes: "Right"),
                YogaPoseReference(poseId: "warrior-ii",               holdDurationSeconds: 45, notes: "Right"),
                YogaPoseReference(poseId: "warrior-iii",              holdDurationSeconds: 30, notes: "Right"),
                YogaPoseReference(poseId: "triangle-pose",            holdDurationSeconds: 40, notes: "Right"),
                YogaPoseReference(poseId: "half-moon-pose",           holdDurationSeconds: 30, notes: "Right"),
                YogaPoseReference(poseId: "warrior-i",                holdDurationSeconds: 45, notes: "Left"),
                YogaPoseReference(poseId: "warrior-ii",               holdDurationSeconds: 45, notes: "Left"),
                YogaPoseReference(poseId: "warrior-iii",              holdDurationSeconds: 30, notes: "Left"),
                YogaPoseReference(poseId: "triangle-pose",            holdDurationSeconds: 40, notes: "Left"),
                YogaPoseReference(poseId: "half-moon-pose",           holdDurationSeconds: 30, notes: "Left"),
                YogaPoseReference(poseId: "eagle-pose",               holdDurationSeconds: 35, notes: "Right"),
                YogaPoseReference(poseId: "eagle-pose",               holdDurationSeconds: 35, notes: "Left"),
                YogaPoseReference(poseId: "goddess-pose",             holdDurationSeconds: 45),
                YogaPoseReference(poseId: "wide-legged-forward-fold", holdDurationSeconds: 60),
                YogaPoseReference(poseId: "bridge-pose",              holdDurationSeconds: 45, repetitions: 3),
                YogaPoseReference(poseId: "butterfly-pose",           holdDurationSeconds: 60),
                YogaPoseReference(poseId: "savasana",                 holdDurationSeconds: 120)
            ],
            safetyNotes: [
                "This is the most vigorous routine in the library — appropriate for experienced practitioners.",
                "Rest in Child's Pose whenever needed between standing sequences."
            ],
            contraindications: [
                "Pregnancy — use Prenatal T1/T2/T3 routines instead",
                "Hypertension — skip Warrior III and Half Moon"
            ],
            isPremium: true
        ),

        // 11. Peak Energy Flow (Ovulation)
        YogaRoutine(
            id: "peak-energy-flow",
            name: "Peak Energy Flow",
            category: .ovulationPower,
            durationMinutes: 25,
            difficulty: .intermediate,
            description: "A confident, expansive sequence that celebrates the body's peak energy during the ovulation phase, with open postures and standing balance work.",
            poses: [
                YogaPoseReference(poseId: "mountain-pose",             holdDurationSeconds: 30),
                YogaPoseReference(poseId: "warrior-i",                 holdDurationSeconds: 45, notes: "Right"),
                YogaPoseReference(poseId: "warrior-ii",                holdDurationSeconds: 45, notes: "Right"),
                YogaPoseReference(poseId: "extended-side-angle",       holdDurationSeconds: 40, notes: "Right"),
                YogaPoseReference(poseId: "warrior-iii",               holdDurationSeconds: 30, notes: "Right — balance challenge"),
                YogaPoseReference(poseId: "warrior-i",                 holdDurationSeconds: 45, notes: "Left"),
                YogaPoseReference(poseId: "warrior-ii",                holdDurationSeconds: 45, notes: "Left"),
                YogaPoseReference(poseId: "extended-side-angle",       holdDurationSeconds: 40, notes: "Left"),
                YogaPoseReference(poseId: "warrior-iii",               holdDurationSeconds: 30, notes: "Left"),
                YogaPoseReference(poseId: "dancers-pose",              holdDurationSeconds: 30, notes: "Right"),
                YogaPoseReference(poseId: "dancers-pose",              holdDurationSeconds: 30, notes: "Left"),
                YogaPoseReference(poseId: "goddess-pose",              holdDurationSeconds: 45),
                YogaPoseReference(poseId: "wide-angle-seated-forward-fold", holdDurationSeconds: 90),
                YogaPoseReference(poseId: "supported-fish-pose",       holdDurationSeconds: 120, notes: "Opening and integration"),
                YogaPoseReference(poseId: "savasana",                  holdDurationSeconds: 120)
            ],
            safetyNotes: [
                "Ovulation is a high-energy phase — this routine matches that vitality without overexertion.",
                "Stay hydrated and listen for signs of fatigue."
            ],
            contraindications: [
                "Joint hypermobility — avoid hyperextension in balance poses",
                "Pregnancy — switch to an appropriate prenatal routine"
            ],
            isPremium: false
        ),

        // 12. PMS Soother (Luteal)
        YogaRoutine(
            id: "pms-soother",
            name: "PMS Soother",
            category: .lutealWindDown,
            durationMinutes: 15,
            difficulty: .beginner,
            description: "A gentle yin-style sequence targeting the hips, lower back, and nervous system to reduce PMS tension, irritability, and fluid retention in the luteal phase.",
            poses: [
                YogaPoseReference(poseId: "easy-pose",                holdDurationSeconds: 60,  notes: "Body scan and breath awareness"),
                YogaPoseReference(poseId: "cat-cow",                  holdDurationSeconds: 60,  notes: "Slow, rhythmic movement"),
                YogaPoseReference(poseId: "childs-pose",              holdDurationSeconds: 90),
                YogaPoseReference(poseId: "thread-the-needle",        holdDurationSeconds: 45,  notes: "Right side"),
                YogaPoseReference(poseId: "thread-the-needle",        holdDurationSeconds: 45,  notes: "Left side"),
                YogaPoseReference(poseId: "butterfly-pose",           holdDurationSeconds: 120),
                YogaPoseReference(poseId: "reclined-butterfly",       holdDurationSeconds: 180),
                YogaPoseReference(poseId: "legs-up-the-wall",         holdDurationSeconds: 300, notes: "Reduces lower limb fluid retention"),
                YogaPoseReference(poseId: "savasana",                 holdDurationSeconds: 120)
            ],
            safetyNotes: [
                "Avoid hot yoga and vigorous movement in the luteal phase.",
                "The long hold in Legs Up the Wall actively reduces ankle swelling."
            ],
            contraindications: [
                "Glaucoma — skip Legs Up the Wall or keep the head elevated"
            ],
            isPremium: false
        ),

        // 13. Mood Balance Flow (Luteal)
        YogaRoutine(
            id: "mood-balance-flow",
            name: "Mood Balance Flow",
            category: .lutealWindDown,
            durationMinutes: 20,
            difficulty: .beginner,
            description: "A mindful 20-minute practice that combines gentle movement with longer passive holds to regulate mood, reduce anxiety, and support hormonal balance in the pre-menstrual week.",
            poses: [
                YogaPoseReference(poseId: "easy-pose",                 holdDurationSeconds: 90,  notes: "Extended breathing practice — 4-count in, 8-count out"),
                YogaPoseReference(poseId: "cat-cow",                   holdDurationSeconds: 90),
                YogaPoseReference(poseId: "puppy-pose",                holdDurationSeconds: 60),
                YogaPoseReference(poseId: "childs-pose",               holdDurationSeconds: 90),
                YogaPoseReference(poseId: "standing-forward-fold",     holdDurationSeconds: 60),
                YogaPoseReference(poseId: "tree-pose",                 holdDurationSeconds: 40,  notes: "Right — grounding"),
                YogaPoseReference(poseId: "tree-pose",                 holdDurationSeconds: 40,  notes: "Left"),
                YogaPoseReference(poseId: "seated-forward-fold",       holdDurationSeconds: 90),
                YogaPoseReference(poseId: "supported-butterfly",       holdDurationSeconds: 300),
                YogaPoseReference(poseId: "legs-up-the-wall",          holdDurationSeconds: 180),
                YogaPoseReference(poseId: "savasana",                  holdDurationSeconds: 180)
            ],
            safetyNotes: [
                "Keep the room warm and quiet.",
                "Journalling or affirmations after practice deepen the mood-regulating benefit."
            ],
            contraindications: [],
            isPremium: false
        )
    ]

    // MARK: - Prenatal Routines (3)

    private static let prenatal: [YogaRoutine] = [

        // 14. First Trimester Gentle
        YogaRoutine(
            id: "prenatal-t1-gentle",
            name: "First Trimester Gentle",
            category: .prenatalT1,
            durationMinutes: 20,
            difficulty: .beginner,
            description: "A safe and energy-conscious sequence for the first trimester, accounting for fatigue and nausea while gently maintaining mobility and pelvic strength.",
            poses: [
                YogaPoseReference(poseId: "easy-pose",           holdDurationSeconds: 60,  notes: "Set intention; breathing"),
                YogaPoseReference(poseId: "cat-cow",             holdDurationSeconds: 90,  notes: "Relieves morning nausea"),
                YogaPoseReference(poseId: "pelvic-tilts",        holdDurationSeconds: 30,  repetitions: 10),
                YogaPoseReference(poseId: "hip-circles",         holdDurationSeconds: 60,  notes: "5 each direction"),
                YogaPoseReference(poseId: "childs-pose",         holdDurationSeconds: 90),
                YogaPoseReference(poseId: "mountain-pose",       holdDurationSeconds: 30),
                YogaPoseReference(poseId: "warrior-i",           holdDurationSeconds: 40,  notes: "Right — gentle version"),
                YogaPoseReference(poseId: "warrior-i",           holdDurationSeconds: 40,  notes: "Left"),
                YogaPoseReference(poseId: "goddess-pose",        holdDurationSeconds: 40),
                YogaPoseReference(poseId: "butterfly-pose",      holdDurationSeconds: 90),
                YogaPoseReference(poseId: "reclined-butterfly",  holdDurationSeconds: 120, notes: "OK to lie flat in T1"),
                YogaPoseReference(poseId: "savasana",            holdDurationSeconds: 180, notes: "Flat is safe in T1")
            ],
            safetyNotes: [
                "Avoid hot yoga, heated studios, and vigorous sequences in the first trimester.",
                "Stop immediately if you experience bleeding, severe cramping, or dizziness.",
                "Avoid lying flat on the back for extended periods if it causes discomfort."
            ],
            contraindications: [
                "IVF cycles — consult your fertility specialist before commencing",
                "History of miscarriage — take medical clearance first"
            ],
            isPremium: false
        ),

        // 15. Second Trimester Flow
        YogaRoutine(
            id: "prenatal-t2-flow",
            name: "Second Trimester Flow",
            category: .prenatalT2,
            durationMinutes: 25,
            difficulty: .beginner,
            description: "A balanced standing and seated routine for the second trimester that builds strength, opens the hips, and avoids any supine positions after week 20.",
            poses: [
                YogaPoseReference(poseId: "easy-pose",               holdDurationSeconds: 60),
                YogaPoseReference(poseId: "cat-cow",                 holdDurationSeconds: 90),
                YogaPoseReference(poseId: "pelvic-tilts",            holdDurationSeconds: 30, repetitions: 10),
                YogaPoseReference(poseId: "hip-circles",             holdDurationSeconds: 60),
                YogaPoseReference(poseId: "bird-dog",                holdDurationSeconds: 30, repetitions: 5, notes: "5 each side — core stability"),
                YogaPoseReference(poseId: "mountain-pose",           holdDurationSeconds: 30),
                YogaPoseReference(poseId: "warrior-i",               holdDurationSeconds: 40, notes: "Right"),
                YogaPoseReference(poseId: "warrior-ii",              holdDurationSeconds: 40, notes: "Right"),
                YogaPoseReference(poseId: "warrior-i",               holdDurationSeconds: 40, notes: "Left"),
                YogaPoseReference(poseId: "warrior-ii",              holdDurationSeconds: 40, notes: "Left"),
                YogaPoseReference(poseId: "goddess-pose",            holdDurationSeconds: 45),
                YogaPoseReference(poseId: "tree-pose",               holdDurationSeconds: 40, notes: "Right — near wall"),
                YogaPoseReference(poseId: "tree-pose",               holdDurationSeconds: 40, notes: "Left"),
                YogaPoseReference(poseId: "butterfly-pose",          holdDurationSeconds: 90),
                YogaPoseReference(poseId: "seated-pigeon",           holdDurationSeconds: 60, notes: "Right"),
                YogaPoseReference(poseId: "seated-pigeon",           holdDurationSeconds: 60, notes: "Left"),
                YogaPoseReference(poseId: "supported-butterfly",     holdDurationSeconds: 180, notes: "On inclined bolster"),
                YogaPoseReference(poseId: "side-lying-savasana",     holdDurationSeconds: 120, notes: "Left side preferred")
            ],
            safetyNotes: [
                "After week 20 do not lie flat on the back for more than 90 seconds.",
                "Use a wall or chair for balance poses as the centre of gravity shifts.",
                "Stay well hydrated and avoid overheating."
            ],
            contraindications: [
                "Placenta praevia — seek medical clearance before any yoga",
                "Pre-eclampsia — avoid vigorous standing sequences"
            ],
            isPremium: false
        ),

        // 16. Third Trimester Comfort
        YogaRoutine(
            id: "prenatal-t3-comfort",
            name: "Third Trimester Comfort",
            category: .prenatalT3,
            durationMinutes: 20,
            difficulty: .beginner,
            description: "A gentle, hip-focused sequence for the third trimester that avoids deep backbends, inversions, and balance poses, instead prioritising pelvic preparation and comfort.",
            poses: [
                YogaPoseReference(poseId: "easy-pose",                holdDurationSeconds: 90,  notes: "Connect with your breath and your baby"),
                YogaPoseReference(poseId: "cat-cow",                  holdDurationSeconds: 90,  notes: "Slow and mindful — helps baby positioning"),
                YogaPoseReference(poseId: "cat-cow-labour",           holdDurationSeconds: 60,  notes: "Introduce labour-rhythm movement"),
                YogaPoseReference(poseId: "pelvic-tilts",             holdDurationSeconds: 30,  repetitions: 10),
                YogaPoseReference(poseId: "hip-circles",              holdDurationSeconds: 60,  notes: "Large, slow circles"),
                YogaPoseReference(poseId: "puppy-pose",               holdDurationSeconds: 60),
                YogaPoseReference(poseId: "childs-pose",              holdDurationSeconds: 90,  notes: "Wide-knee; bolster under torso"),
                YogaPoseReference(poseId: "squat-with-support",       holdDurationSeconds: 45,  repetitions: 3, notes: "Hold a chair; 3 rounds"),
                YogaPoseReference(poseId: "goddess-pose",             holdDurationSeconds: 45),
                YogaPoseReference(poseId: "butterfly-pose",           holdDurationSeconds: 90),
                YogaPoseReference(poseId: "modified-pigeon-prenatal", holdDurationSeconds: 60,  notes: "Right side"),
                YogaPoseReference(poseId: "modified-pigeon-prenatal", holdDurationSeconds: 60,  notes: "Left side"),
                YogaPoseReference(poseId: "supported-butterfly",      holdDurationSeconds: 180, notes: "On inclined bolster"),
                YogaPoseReference(poseId: "side-lying-savasana",      holdDurationSeconds: 180, notes: "Left side; pillow between knees")
            ],
            safetyNotes: [
                "Avoid lying flat on the back entirely in the third trimester.",
                "Stop immediately with any pelvic pain, shortness of breath, or unusual discharge.",
                "Keep sessions under 30 minutes in the final weeks; listen to the body.",
                "Attend only prenatal-specific classes taught by a certified instructor."
            ],
            contraindications: [
                "Placenta praevia or low-lying placenta",
                "Preterm labour symptoms — stop all exercise and seek care",
                "Uncontrolled gestational hypertension"
            ],
            isPremium: false
        )
    ]

    // MARK: - Postnatal Routines (2)

    private static let postnatal: [YogaRoutine] = [

        // 17. Postnatal Recovery
        YogaRoutine(
            id: "postnatal-recovery",
            name: "Postnatal Recovery",
            category: .postpartumRecovery,
            durationMinutes: 15,
            difficulty: .beginner,
            description: "A gentle, healing sequence for the early postnatal period (after medical clearance) to reconnect with the breath, release tension from birth, and begin restoring mobility.",
            poses: [
                YogaPoseReference(poseId: "side-lying-savasana",  holdDurationSeconds: 120, notes: "Begin resting; breathe into the ribcage"),
                YogaPoseReference(poseId: "pelvic-tilts",         holdDurationSeconds: 30,  repetitions: 5, notes: "Very gentle — reconnect with deep core"),
                YogaPoseReference(poseId: "easy-pose",            holdDurationSeconds: 90),
                YogaPoseReference(poseId: "cat-cow",              holdDurationSeconds: 60,  notes: "5 gentle rounds"),
                YogaPoseReference(poseId: "childs-pose",          holdDurationSeconds: 90),
                YogaPoseReference(poseId: "butterfly-pose",       holdDurationSeconds: 90),
                YogaPoseReference(poseId: "supported-butterfly",  holdDurationSeconds: 180, notes: "Restorative — good for breastfeeding recovery"),
                YogaPoseReference(poseId: "supported-fish-pose",  holdDurationSeconds: 180, notes: "Opens chest after breastfeeding posture"),
                YogaPoseReference(poseId: "savasana",             holdDurationSeconds: 180)
            ],
            safetyNotes: [
                "Obtain medical clearance before commencing — typically 6 weeks post-vaginal delivery, 8–12 weeks post-caesarean.",
                "Avoid sit-ups, crunches, or any pose that causes coning or doming of the abdomen.",
                "If experiencing pelvic floor symptoms (leaking, prolapse), see a women's health physiotherapist first.",
                "Fatigue is normal postnatally; rest in Child's Pose or Savasana whenever needed."
            ],
            contraindications: [
                "Diastasis recti (abdominal separation) — avoid spinal flexion exercises until assessed",
                "Active bleeding or infection — defer all exercise until resolved"
            ],
            isPremium: false
        ),

        // 18. Core Restore
        YogaRoutine(
            id: "core-restore",
            name: "Core Restore",
            category: .postpartumRecovery,
            durationMinutes: 20,
            difficulty: .beginner,
            description: "A progressive postnatal core sequence (suitable after initial recovery) that rebuilds transverse abdominis and pelvic floor function through gentle, functional movement.",
            poses: [
                YogaPoseReference(poseId: "easy-pose",          holdDurationSeconds: 60,  notes: "Breath awareness — 360-degree ribcage breathing"),
                YogaPoseReference(poseId: "pelvic-tilts",       holdDurationSeconds: 30,  repetitions: 10, notes: "With core draw-in"),
                YogaPoseReference(poseId: "tabletop",           holdDurationSeconds: 30,  notes: "Neutral spine — assess core connection"),
                YogaPoseReference(poseId: "bird-dog",           holdDurationSeconds: 30,  repetitions: 5, notes: "5 each side — slow and controlled"),
                YogaPoseReference(poseId: "cat-cow",            holdDurationSeconds: 60),
                YogaPoseReference(poseId: "childs-pose",        holdDurationSeconds: 60),
                YogaPoseReference(poseId: "bridge-pose",        holdDurationSeconds: 40,  repetitions: 5, notes: "5 slow lifts and lowers — not held"),
                YogaPoseReference(poseId: "butterfly-pose",     holdDurationSeconds: 60),
                YogaPoseReference(poseId: "figure-four-stretch",holdDurationSeconds: 60,  notes: "Right"),
                YogaPoseReference(poseId: "figure-four-stretch",holdDurationSeconds: 60,  notes: "Left"),
                YogaPoseReference(poseId: "supported-fish-pose",holdDurationSeconds: 120),
                YogaPoseReference(poseId: "savasana",           holdDurationSeconds: 120)
            ],
            safetyNotes: [
                "Cease any exercise that causes coning, doming, or increased pelvic floor symptoms.",
                "Progress is individual — do not compare to pre-pregnancy performance.",
                "Recommended to combine with pelvic floor physiotherapy."
            ],
            contraindications: [
                "Diastasis recti — consult a physiotherapist before Bridge Pose and Bird-Dog",
                "Less than 6 weeks postpartum"
            ],
            isPremium: false
        )
    ]

    // MARK: - Stress / Emotional Wellbeing Routines (2)

    private static let emotional: [YogaRoutine] = [

        // 19. Anxiety Relief
        YogaRoutine(
            id: "anxiety-relief",
            name: "Anxiety Relief",
            category: .breathing,
            durationMinutes: 15,
            difficulty: .beginner,
            description: "A breath-led, grounding sequence that directly down-regulates the nervous system to relieve anxiety, overwhelm, and racing thoughts.",
            poses: [
                YogaPoseReference(poseId: "easy-pose",             holdDurationSeconds: 120, notes: "Extended 4-7-8 breathing: inhale 4, hold 7, exhale 8"),
                YogaPoseReference(poseId: "childs-pose",           holdDurationSeconds: 120, notes: "Forehead on floor activates the vagus nerve"),
                YogaPoseReference(poseId: "cat-cow",               holdDurationSeconds: 60,  notes: "Slow and breath-led only"),
                YogaPoseReference(poseId: "puppy-pose",            holdDurationSeconds: 60),
                YogaPoseReference(poseId: "butterfly-pose",        holdDurationSeconds: 90),
                YogaPoseReference(poseId: "supported-childs-pose", holdDurationSeconds: 180),
                YogaPoseReference(poseId: "reclined-butterfly",    holdDurationSeconds: 180),
                YogaPoseReference(poseId: "legs-up-the-wall",      holdDurationSeconds: 300, notes: "Mild inversion calms the adrenals"),
                YogaPoseReference(poseId: "savasana",              holdDurationSeconds: 180, notes: "Progressive muscle relaxation scan")
            ],
            safetyNotes: [
                "This routine may be used as a panic-relief intervention.",
                "An eyebag or lavender eye pillow in Savasana deepens the parasympathetic response.",
                "Combine with professional mental health support if anxiety is persistent."
            ],
            contraindications: [
                "Glaucoma — skip Legs Up the Wall"
            ],
            isPremium: false
        ),

        // 20. Deep Relaxation
        YogaRoutine(
            id: "deep-relaxation",
            name: "Deep Relaxation",
            category: .breathing,
            durationMinutes: 25,
            difficulty: .beginner,
            description: "A 25-minute restorative practice with extended holds in fully-supported poses, designed to provide deep, nourishing rest for burnout, chronic stress, and exhaustion.",
            poses: [
                YogaPoseReference(poseId: "easy-pose",                 holdDurationSeconds: 90,  notes: "Sankalpa — set a healing intention"),
                YogaPoseReference(poseId: "supported-childs-pose",     holdDurationSeconds: 300),
                YogaPoseReference(poseId: "supported-butterfly",       holdDurationSeconds: 600, notes: "Longest hold — completely surrender to the support"),
                YogaPoseReference(poseId: "supported-fish-pose",       holdDurationSeconds: 300),
                YogaPoseReference(poseId: "legs-up-wall-restorative",  holdDurationSeconds: 600),
                YogaPoseReference(poseId: "side-lying-savasana",       holdDurationSeconds: 300, notes: "Transition gently"),
                YogaPoseReference(poseId: "savasana",                  holdDurationSeconds: 300, notes: "Full yoga nidra / body scan")
            ],
            safetyNotes: [
                "Prepare all props before beginning — bolster, 2 blocks, blankets, eye pillow.",
                "Keep the room warm (18–22 °C) as the body temperature drops during deep rest.",
                "This practice is suitable during any menstrual cycle phase and throughout most of pregnancy with modifications."
            ],
            contraindications: [
                "Pregnancy beyond 20 weeks — use Side-Lying Savasana instead of flat Savasana; use inclined bolster for Supported Butterfly and Fish"
            ],
            isPremium: true
        )
    ]
}
