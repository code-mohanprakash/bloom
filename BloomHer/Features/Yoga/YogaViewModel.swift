//
//  YogaViewModel.swift
//  BloomHer
//
//  @Observable ViewModel for the Yoga & Movement feature.
//  Owns phase-aware routine recommendations, session history,
//  weekly stats, and pregnancy-safe filtering.
//

import Foundation

// MARK: - YogaViewModel

/// Drives all yoga & movement screens.
///
/// Phase-aware recommendations are refreshed whenever `currentPhase` or
/// `isPregnant` / `currentTrimester` change. All data access is delegated
/// to `YogaRepositoryProtocol` so the ViewModel remains testable without a
/// live SwiftData context.
@Observable
@MainActor
final class YogaViewModel {

    // MARK: - Dependencies

    private let yogaRepository: YogaRepositoryProtocol

    // MARK: - Published State

    /// The currently selected browse category (nil = show all).
    var selectedCategory: ExerciseCategory?

    /// Live text entered in the search field.
    var searchText: String = ""

    /// The three (or fewer) recommended routines for the user's current phase.
    var recommendedRoutines: [YogaRoutine] = []

    /// All available static routines.
    var allRoutines: [YogaRoutine] = []

    /// The three most recent completed sessions.
    var recentSessions: [YogaSession] = []

    /// Sum of completed session durations within the current ISO week.
    var totalMinutesThisWeek: Int = 0

    /// The user's current menstrual cycle phase.
    var currentPhase: CyclePhase = .follicular

    /// Whether the user is currently pregnant.
    var isPregnant: Bool = false

    /// Trimester (1, 2, or 3) when `isPregnant` is true; nil otherwise.
    var currentTrimester: Int? = nil

    /// Whether an async data load is in progress.
    var isLoading: Bool = false

    // MARK: - Computed: filtered routines

    /// Routines filtered by the active category and search text.
    var filteredRoutines: [YogaRoutine] {
        var result = allRoutines

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        let query = searchText.trimmingCharacters(in: .whitespaces)
        if !query.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.description.localizedCaseInsensitiveContains(query)
            }
        }

        return result.sorted { $0.difficulty.sortOrder < $1.difficulty.sortOrder }
    }

    // MARK: - Init

    init(yogaRepository: YogaRepositoryProtocol) {
        self.yogaRepository = yogaRepository
    }

    // MARK: - Public Methods

    /// Loads all data: static content, session history, weekly stats.
    func loadData() {
        isLoading = true
        allRoutines = YogaContentProvider.allRoutines
        recentSessions = yogaRepository.fetchRecentSessions(count: 3)
        totalMinutesThisWeek = yogaRepository.totalMinutesThisWeek()
        refreshRecommendations()
        isLoading = false
    }

    /// Returns routines belonging to the given category.
    func routines(for category: ExerciseCategory) -> [YogaRoutine] {
        allRoutines.filter { $0.category == category }
    }

    /// Rebuilds phase-aware / pregnancy-aware recommendations.
    func refreshRecommendations() {
        if isPregnant, let trimester = currentTrimester {
            let targetCategory: ExerciseCategory
            switch trimester {
            case 1: targetCategory = .prenatalT1
            case 2: targetCategory = .prenatalT2
            default: targetCategory = .prenatalT3
            }
            recommendedRoutines = Array(
                allRoutines
                    .filter { $0.category == targetCategory }
                    .prefix(3)
            )
        } else {
            let targetCategory = currentPhase.preferredCategory
            recommendedRoutines = Array(
                allRoutines
                    .filter { $0.category == targetCategory }
                    .prefix(3)
            )
        }
    }

    /// Saves a completed session to the repository and refreshes stats.
    func saveSession(_ session: YogaSession) {
        yogaRepository.saveSession(session)
        recentSessions = yogaRepository.fetchRecentSessions(count: 3)
        totalMinutesThisWeek = yogaRepository.totalMinutesThisWeek()
    }

    // MARK: - Category helpers

    /// Routine count badge for a given category.
    func routineCount(for category: ExerciseCategory) -> Int {
        allRoutines.filter { $0.category == category }.count
    }

    /// Returns `true` if the category is relevant given the user's current state.
    func isCategoryRelevant(_ category: ExerciseCategory) -> Bool {
        if isPregnant {
            return category.isPrenatal || category == .pelvicFloor || category == .breathing
        }
        return !category.isPrenatal && !category.isPostpartum
    }

    /// The ordered list of categories the user should see.
    var visibleCategories: [ExerciseCategory] {
        ExerciseCategory.allCases.filter { isCategoryRelevant($0) }
    }
}

// MARK: - CyclePhase + Preferred Category

private extension CyclePhase {
    var preferredCategory: ExerciseCategory {
        switch self {
        case .menstrual:  return .menstrualYoga
        case .follicular: return .follicularEnergy
        case .ovulation:  return .ovulationPower
        case .luteal:     return .lutealWindDown
        }
    }
}

// MARK: - Difficulty + Sort Order

private extension Difficulty {
    var sortOrder: Int {
        switch self {
        case .beginner:     return 0
        case .intermediate: return 1
        case .advanced:     return 2
        }
    }
}

// MARK: - YogaContentProvider

/// Static seed data. In a production build this would come from a bundled
/// JSON file or remote config; kept inline here for clarity.
enum YogaContentProvider {

    static let allRoutines: [YogaRoutine] = menstrualRoutines
        + follicularRoutines
        + ovulationRoutines
        + lutealRoutines
        + prenatalRoutines
        + specialRoutines

    // MARK: Menstrual

    private static let menstrualRoutines: [YogaRoutine] = [
        YogaRoutine(
            id: "men-gentle-flow",
            name: "Gentle Menstrual Flow",
            category: .menstrualYoga,
            durationMinutes: 20,
            difficulty: .beginner,
            description: "A soothing sequence to ease cramping and lower back tension during your period. Slow, nurturing movements to honour your body.",
            poses: [
                YogaPoseReference(poseId: "child-pose", holdDurationSeconds: 60),
                YogaPoseReference(poseId: "supine-twist", holdDurationSeconds: 45),
                YogaPoseReference(poseId: "legs-up-wall", holdDurationSeconds: 120),
                YogaPoseReference(poseId: "savasana", holdDurationSeconds: 180)
            ],
            safetyNotes: ["Avoid inversions during heavy flow", "Listen to your body — rest if needed"],
            contraindications: ["Heavy bleeding"],
            isPremium: false
        ),
        YogaRoutine(
            id: "men-restorative",
            name: "Restorative Rest",
            category: .menstrualYoga,
            durationMinutes: 30,
            difficulty: .beginner,
            description: "Deep restorative postures held for extended durations to calm the nervous system and reduce period pain.",
            poses: [
                YogaPoseReference(poseId: "supported-butterfly", holdDurationSeconds: 120),
                YogaPoseReference(poseId: "child-pose", holdDurationSeconds: 90),
                YogaPoseReference(poseId: "savasana", holdDurationSeconds: 300)
            ],
            safetyNotes: ["Use props for all postures", "Warmth aids muscle relaxation"],
            contraindications: [],
            isPremium: false
        ),
        YogaRoutine(
            id: "men-cramp-relief",
            name: "Cramp Relief Flow",
            category: .menstrualYoga,
            durationMinutes: 15,
            difficulty: .beginner,
            description: "Targeted poses focusing on the lower abdomen and hips to provide fast relief from menstrual cramps.",
            poses: [
                YogaPoseReference(poseId: "wind-relieving", holdDurationSeconds: 30),
                YogaPoseReference(poseId: "supine-butterfly", holdDurationSeconds: 60),
                YogaPoseReference(poseId: "child-pose", holdDurationSeconds: 60)
            ],
            safetyNotes: [],
            contraindications: [],
            isPremium: false
        )
    ]

    // MARK: Follicular

    private static let follicularRoutines: [YogaRoutine] = [
        YogaRoutine(
            id: "fol-energise",
            name: "Energising Sun Flow",
            category: .follicularEnergy,
            durationMinutes: 35,
            difficulty: .intermediate,
            description: "A dynamic vinyasa sequence harnessing rising oestrogen energy. Build heat, improve circulation, and boost your mood.",
            poses: [
                YogaPoseReference(poseId: "sun-salutation-a", holdDurationSeconds: 5, repetitions: 5),
                YogaPoseReference(poseId: "warrior-1", holdDurationSeconds: 45),
                YogaPoseReference(poseId: "warrior-2", holdDurationSeconds: 45),
                YogaPoseReference(poseId: "triangle", holdDurationSeconds: 45),
                YogaPoseReference(poseId: "savasana", holdDurationSeconds: 120)
            ],
            safetyNotes: [],
            contraindications: [],
            isPremium: false
        ),
        YogaRoutine(
            id: "fol-strength",
            name: "Core & Strength",
            category: .follicularEnergy,
            durationMinutes: 40,
            difficulty: .intermediate,
            description: "Build functional strength through standing poses and core work, aligned with the rising-energy follicular phase.",
            poses: [
                YogaPoseReference(poseId: "plank", holdDurationSeconds: 30),
                YogaPoseReference(poseId: "warrior-3", holdDurationSeconds: 30),
                YogaPoseReference(poseId: "chair-pose", holdDurationSeconds: 30),
                YogaPoseReference(poseId: "boat-pose", holdDurationSeconds: 20)
            ],
            safetyNotes: [],
            contraindications: [],
            isPremium: true
        )
    ]

    // MARK: Ovulation

    private static let ovulationRoutines: [YogaRoutine] = [
        YogaRoutine(
            id: "ov-power-flow",
            name: "Peak Power Flow",
            category: .ovulationPower,
            durationMinutes: 45,
            difficulty: .advanced,
            description: "Harness peak-cycle energy with an advanced power vinyasa that challenges strength, balance, and endurance.",
            poses: [
                YogaPoseReference(poseId: "sun-salutation-b", holdDurationSeconds: 5, repetitions: 6),
                YogaPoseReference(poseId: "warrior-3", holdDurationSeconds: 45),
                YogaPoseReference(poseId: "half-moon", holdDurationSeconds: 30),
                YogaPoseReference(poseId: "crow-pose", holdDurationSeconds: 20),
                YogaPoseReference(poseId: "savasana", holdDurationSeconds: 120)
            ],
            safetyNotes: ["Warm up thoroughly", "Hydrate well"],
            contraindications: [],
            isPremium: true
        ),
        YogaRoutine(
            id: "ov-hip-opener",
            name: "Hip Opening Flow",
            category: .ovulationPower,
            durationMinutes: 30,
            difficulty: .intermediate,
            description: "Deep hip openers to release tension and celebrate your most fertile phase with mobility and freedom.",
            poses: [
                YogaPoseReference(poseId: "pigeon-pose", holdDurationSeconds: 60),
                YogaPoseReference(poseId: "lizard-pose", holdDurationSeconds: 45),
                YogaPoseReference(poseId: "butterfly", holdDurationSeconds: 60)
            ],
            safetyNotes: [],
            contraindications: ["Knee injuries — use modifications"],
            isPremium: false
        )
    ]

    // MARK: Luteal

    private static let lutealRoutines: [YogaRoutine] = [
        YogaRoutine(
            id: "lut-wind-down",
            name: "Evening Wind Down",
            category: .lutealWindDown,
            durationMinutes: 25,
            difficulty: .beginner,
            description: "A calming sequence for the luteal phase to reduce PMS tension, support sleep, and calm the nervous system.",
            poses: [
                YogaPoseReference(poseId: "forward-fold", holdDurationSeconds: 60),
                YogaPoseReference(poseId: "supine-twist", holdDurationSeconds: 60),
                YogaPoseReference(poseId: "legs-up-wall", holdDurationSeconds: 120),
                YogaPoseReference(poseId: "savasana", holdDurationSeconds: 180)
            ],
            safetyNotes: [],
            contraindications: [],
            isPremium: false
        ),
        YogaRoutine(
            id: "lut-yin",
            name: "Yin for PMS Relief",
            category: .lutealWindDown,
            durationMinutes: 40,
            difficulty: .beginner,
            description: "Long-held yin poses targeting the hips, lower back, and inner thighs to ease common luteal-phase discomforts.",
            poses: [
                YogaPoseReference(poseId: "dragon-pose", holdDurationSeconds: 180),
                YogaPoseReference(poseId: "sleeping-swan", holdDurationSeconds: 180),
                YogaPoseReference(poseId: "supported-bridge", holdDurationSeconds: 120)
            ],
            safetyNotes: [],
            contraindications: [],
            isPremium: false
        )
    ]

    // MARK: Prenatal

    private static let prenatalRoutines: [YogaRoutine] = [
        YogaRoutine(
            id: "pre-t1-gentle",
            name: "First Trimester Gentle",
            category: .prenatalT1,
            durationMinutes: 20,
            difficulty: .beginner,
            description: "Safe, low-impact yoga to ease first-trimester nausea and fatigue while maintaining gentle mobility.",
            poses: [
                YogaPoseReference(poseId: "mountain-pose", holdDurationSeconds: 30),
                YogaPoseReference(poseId: "cat-cow", holdDurationSeconds: 60, repetitions: 10),
                YogaPoseReference(poseId: "supported-warrior", holdDurationSeconds: 30)
            ],
            safetyNotes: ["Avoid lying flat on back after 12 weeks", "Stay hydrated", "Stop if dizzy"],
            contraindications: ["Hyperemesis gravidarum — rest first"],
            isPremium: false
        ),
        YogaRoutine(
            id: "pre-t2-mobility",
            name: "Second Trimester Mobility",
            category: .prenatalT2,
            durationMinutes: 30,
            difficulty: .beginner,
            description: "Modified strength and mobility sequence for the second trimester, supporting growing belly and relieving round ligament tension.",
            poses: [
                YogaPoseReference(poseId: "side-angle-modified", holdDurationSeconds: 30),
                YogaPoseReference(poseId: "cat-cow", holdDurationSeconds: 60),
                YogaPoseReference(poseId: "supported-squat", holdDurationSeconds: 45)
            ],
            safetyNotes: ["Use wall or chair for balance", "Avoid deep twists", "Breathe fully"],
            contraindications: ["Placenta previa", "Pre-eclampsia"],
            isPremium: false
        ),
        YogaRoutine(
            id: "pre-t3-prep",
            name: "Third Trimester Prep",
            category: .prenatalT3,
            durationMinutes: 25,
            difficulty: .beginner,
            description: "Gentle movements to ease pelvic pressure, prepare for labour, and maintain comfort in the final weeks.",
            poses: [
                YogaPoseReference(poseId: "cat-cow", holdDurationSeconds: 60),
                YogaPoseReference(poseId: "supported-squat", holdDurationSeconds: 60),
                YogaPoseReference(poseId: "child-pose-modified", holdDurationSeconds: 60)
            ],
            safetyNotes: ["Keep knees wide", "Use props liberally", "Avoid inversions completely"],
            contraindications: ["Any pregnancy complication — consult your midwife"],
            isPremium: false
        )
    ]

    // MARK: Special

    private static let specialRoutines: [YogaRoutine] = [
        YogaRoutine(
            id: "spec-postpartum",
            name: "Postpartum Restoration",
            category: .postpartumRecovery,
            durationMinutes: 20,
            difficulty: .beginner,
            description: "Gentle core and pelvic floor restoration for after birth. Progress slowly and always follow your healthcare provider's clearance.",
            poses: [
                YogaPoseReference(poseId: "diaphragmatic-breathing", holdDurationSeconds: 120),
                YogaPoseReference(poseId: "pelvic-floor-activation", holdDurationSeconds: 60),
                YogaPoseReference(poseId: "gentle-bridge", holdDurationSeconds: 30)
            ],
            safetyNotes: ["Wait for 6-week clearance before starting", "Stop if experiencing pain", "Stay well-hydrated if breastfeeding"],
            contraindications: ["Before 6-week postnatal check"],
            isPremium: false
        ),
        YogaRoutine(
            id: "spec-labour-prep",
            name: "Labour Preparation",
            category: .labourPrep,
            durationMinutes: 35,
            difficulty: .beginner,
            description: "Positioning, breathing, and mobility work to prepare your body and mind for labour. Focuses on hip opening and breath control.",
            poses: [
                YogaPoseReference(poseId: "supported-squat", holdDurationSeconds: 60),
                YogaPoseReference(poseId: "figure-4", holdDurationSeconds: 45),
                YogaPoseReference(poseId: "birth-ball-circles", holdDurationSeconds: 120),
                YogaPoseReference(poseId: "labour-breathing", holdDurationSeconds: 180)
            ],
            safetyNotes: ["Best practiced from 36 weeks", "Have support nearby"],
            contraindications: ["Before 36 weeks unless advised by midwife"],
            isPremium: false
        )
    ]
}

// MARK: - Static Pose Library

/// Provides the full catalogue of `YogaPose` objects for display in the library
/// and active routine player.
enum YogaPoseLibrary {

    static let allPoses: [YogaPose] = [

        YogaPose(
            id: "child-pose",
            name: "Child's Pose",
            sanskritName: "Balasana",
            instructions: [
                "Kneel on the floor with big toes touching.",
                "Sit back onto your heels and fold forward.",
                "Extend arms forward or rest alongside the body.",
                "Breathe deeply into the back of your body.",
                "Rest the forehead on the mat."
            ],
            benefits: ["Releases lower back tension", "Calms the nervous system", "Gently stretches hips and thighs"],
            contraindications: ["Knee injuries", "Ankle problems"],
            defaultHoldDurationSeconds: 60,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe, trimester2: .modified, trimester3: .modified, postpartum: .safe,
                notes: "Widen knees to accommodate belly in T2/T3"
            ),
            muscleGroups: ["Lower back", "Hips", "Thighs"]
        ),

        YogaPose(
            id: "supine-twist",
            name: "Supine Spinal Twist",
            sanskritName: "Supta Matsyendrasana",
            instructions: [
                "Lie on your back and hug knees to chest.",
                "Drop both knees to one side.",
                "Extend arms out in a T shape.",
                "Turn the head opposite to knees.",
                "Breathe and let gravity deepen the twist."
            ],
            benefits: ["Releases spinal tension", "Massages abdominal organs", "Improves spinal mobility"],
            contraindications: ["Disc herniation", "Pregnancy (use modified version)"],
            defaultHoldDurationSeconds: 45,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .modified, trimester2: .avoid, trimester3: .avoid, postpartum: .modified,
                notes: "Avoid deep twists; gentle side-lying stretch only"
            ),
            muscleGroups: ["Spine", "Obliques", "Glutes"]
        ),

        YogaPose(
            id: "legs-up-wall",
            name: "Legs Up the Wall",
            sanskritName: "Viparita Karani",
            instructions: [
                "Sit with one hip touching the wall.",
                "Swing legs up the wall as you lower your back to the floor.",
                "Rest arms by your sides, palms up.",
                "Breathe deeply and let the legs rest fully.",
                "Stay for 2–5 minutes."
            ],
            benefits: ["Reduces swelling in legs", "Calms nervous system", "Relieves lower back ache"],
            contraindications: ["Glaucoma", "High blood pressure (modified)"],
            defaultHoldDurationSeconds: 120,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe, trimester2: .modified, trimester3: .avoid, postpartum: .safe,
                notes: "Avoid in T3 — use elevated legs on pillows instead"
            ),
            muscleGroups: ["Hamstrings", "Lower back", "Calves"]
        ),

        YogaPose(
            id: "savasana",
            name: "Corpse Pose",
            sanskritName: "Savasana",
            instructions: [
                "Lie flat on your back.",
                "Let feet fall out naturally, arms slightly away from the body.",
                "Close your eyes and release all effort.",
                "Breathe naturally and allow full relaxation.",
                "Remain still for the designated time."
            ],
            benefits: ["Complete relaxation", "Integrates the practice", "Reduces cortisol"],
            contraindications: [],
            defaultHoldDurationSeconds: 180,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Full body"]
        ),

        YogaPose(
            id: "warrior-1",
            name: "Warrior I",
            sanskritName: "Virabhadrasana I",
            instructions: [
                "Step one foot forward into a lunge.",
                "Back foot turns 45 degrees.",
                "Bend front knee to 90 degrees over the ankle.",
                "Raise arms overhead with palms facing.",
                "Draw shoulder blades down and lift the chest."
            ],
            benefits: ["Builds leg strength", "Opens hip flexors", "Improves focus and stamina"],
            contraindications: ["Knee injuries", "High blood pressure"],
            defaultHoldDurationSeconds: 45,
            difficulty: .intermediate,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe, trimester2: .modified, trimester3: .modified, postpartum: .safe,
                notes: "Widen stance for balance as bump grows"
            ),
            muscleGroups: ["Quadriceps", "Glutes", "Hip flexors", "Shoulders"]
        ),

        YogaPose(
            id: "cat-cow",
            name: "Cat–Cow",
            sanskritName: "Marjaryasana–Bitilasana",
            instructions: [
                "Start on hands and knees with a neutral spine.",
                "Inhale: drop the belly, lift the tailbone and chest (Cow).",
                "Exhale: round the spine toward the ceiling, tuck chin (Cat).",
                "Move slowly, linking breath to movement.",
                "Repeat 10 times."
            ],
            benefits: ["Relieves back tension", "Improves spinal mobility", "Safe for all trimesters"],
            contraindications: ["Wrist injuries — use fists"],
            defaultHoldDurationSeconds: 60,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Spine", "Core", "Neck"]
        ),

        YogaPose(
            id: "pigeon-pose",
            name: "Pigeon Pose",
            sanskritName: "Eka Pada Rajakapotasana",
            instructions: [
                "From downward dog, bring one knee forward behind the wrist.",
                "Extend the other leg straight behind.",
                "Square the hips as much as possible.",
                "Walk hands forward and fold over the front leg.",
                "Breathe into the outer hip."
            ],
            benefits: ["Deep hip opener", "Releases piriformis tension", "Improves external rotation"],
            contraindications: ["Knee injuries", "Sacroiliac pain", "Hip replacement"],
            defaultHoldDurationSeconds: 60,
            difficulty: .intermediate,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe, trimester2: .modified, trimester3: .avoid, postpartum: .modified,
                notes: "Use supported variation with blanket under hip"
            ),
            muscleGroups: ["Hip rotators", "Glutes", "Piriformis"]
        ),

        YogaPose(
            id: "supported-squat",
            name: "Supported Squat",
            sanskritName: "Malasana",
            instructions: [
                "Stand with feet wider than hip-width, toes out.",
                "Lower into a deep squat, using a block or rolled blanket under heels if needed.",
                "Bring palms together at chest, elbows pressing inner knees wide.",
                "Keep the spine tall and breathe deeply.",
                "Use a wall or chair for balance if needed."
            ],
            benefits: ["Opens pelvis", "Prepares for labour", "Strengthens pelvic floor"],
            contraindications: ["SPD/pelvic girdle pain", "Knee injuries"],
            defaultHoldDurationSeconds: 45,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe, trimester2: .safe, trimester3: .safe, postpartum: .modified,
                notes: "Excellent for labour prep; avoid if SPD diagnosed"
            ),
            muscleGroups: ["Pelvic floor", "Inner thighs", "Glutes", "Ankles"]
        ),

        YogaPose(
            id: "mountain-pose",
            name: "Mountain Pose",
            sanskritName: "Tadasana",
            instructions: [
                "Stand with feet hip-width apart, toes pointing forward.",
                "Distribute weight evenly through both feet.",
                "Engage thighs gently, lengthen the spine.",
                "Roll shoulders back and down.",
                "Arms hang naturally by your sides. Breathe."
            ],
            benefits: ["Improves posture", "Grounds and centres", "Foundation of all standing poses"],
            contraindications: [],
            defaultHoldDurationSeconds: 30,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Full body", "Core", "Posture muscles"]
        ),

        YogaPose(
            id: "forward-fold",
            name: "Standing Forward Fold",
            sanskritName: "Uttanasana",
            instructions: [
                "Stand tall in Mountain Pose.",
                "Exhale and hinge from the hips, folding forward.",
                "Let the head hang heavy.",
                "Bend knees generously if hamstrings are tight.",
                "Hold for the prescribed time, breathing into the back body."
            ],
            benefits: ["Stretches hamstrings and calves", "Calms the nervous system", "Releases spinal tension"],
            contraindications: ["Herniated disc", "Glaucoma"],
            defaultHoldDurationSeconds: 60,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe, trimester2: .modified, trimester3: .avoid, postpartum: .safe,
                notes: "Widen feet and bend knees in pregnancy"
            ),
            muscleGroups: ["Hamstrings", "Lower back", "Calves"]
        )
    ]

    static func pose(forId id: String) -> YogaPose? {
        allPoses.first { $0.id == id }
    }
}
