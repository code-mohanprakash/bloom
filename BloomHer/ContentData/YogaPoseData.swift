import Foundation

// MARK: - YogaPoseData

/// A static library of curated yoga poses used across BloomHer's yoga features.
///
/// Pose IDs use kebab-case and are the stable reference key used in
/// `YogaPoseReference.poseId` inside every `YogaRoutine`.  Keep IDs
/// unchanged once shipped — changing them will break persisted sessions.
enum YogaPoseData {

    // MARK: - Public Interface

    /// The complete pose library.
    static let poses: [YogaPose] = standing + seated + floorSupine + handsAndKnees + balance + restorative + prenatal

    /// Returns a single pose by its stable string identifier, or `nil` if not found.
    static func pose(byId id: String) -> YogaPose? {
        poses.first { $0.id == id }
    }

    // MARK: - Standing Poses (12)

    private static let standing: [YogaPose] = [

        // 1. Mountain Pose
        YogaPose(
            id: "mountain-pose",
            name: "Mountain Pose",
            sanskritName: "Tadasana",
            instructions: [
                "Stand with feet hip-width apart and parallel, weight evenly distributed across all four corners of each foot.",
                "Engage your quadriceps to lift the kneecaps slightly, without locking the knees.",
                "Draw your lower abdomen in and up gently, lengthen your tailbone toward the floor.",
                "Roll your shoulders back and down, broaden across the collarbones, and let arms hang naturally with palms facing forward.",
                "Crown of the head reaches toward the ceiling; breathe steadily for 5–10 full breaths."
            ],
            benefits: [
                "Improves posture and body awareness",
                "Strengthens thighs, knees, and ankles",
                "Establishes grounding and calm focus"
            ],
            contraindications: [
                "Headaches or low blood pressure — sit or lean against a wall",
                "Insomnia — keep the session brief"
            ],
            defaultHoldDurationSeconds: 30,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .safe,
                postpartum: .safe,
                notes: "Stand with feet slightly wider in the third trimester for added stability."
            ),
            muscleGroups: ["Quadriceps", "Glutes", "Core", "Upper back"]
        ),

        // 2. Warrior I
        YogaPose(
            id: "warrior-i",
            name: "Warrior I",
            sanskritName: "Virabhadrasana I",
            instructions: [
                "From Mountain Pose, step your left foot back about 3–4 feet; turn it out 45 degrees.",
                "Bend your right knee to 90 degrees, keeping it directly over the ankle.",
                "Square your hips to the front of the mat as much as possible.",
                "Inhale, reach both arms overhead with palms facing each other; gaze forward or gently up.",
                "Hold for 5 breaths, then repeat on the other side."
            ],
            benefits: [
                "Strengthens legs, glutes, and core",
                "Stretches hip flexors and chest",
                "Builds stamina and mental determination"
            ],
            contraindications: [
                "High blood pressure — keep arms at shoulder height",
                "Knee or hip injuries — reduce the depth of the lunge"
            ],
            defaultHoldDurationSeconds: 45,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .modified,
                postpartum: .safe,
                notes: "In the third trimester widen the stance for balance and use a chair for support if needed."
            ),
            muscleGroups: ["Quadriceps", "Hip flexors", "Glutes", "Shoulders", "Core"]
        ),

        // 3. Warrior II
        YogaPose(
            id: "warrior-ii",
            name: "Warrior II",
            sanskritName: "Virabhadrasana II",
            instructions: [
                "Step feet wide apart (about 4 feet); turn your right foot out 90 degrees and left foot in slightly.",
                "Bend the right knee to 90 degrees, shin perpendicular to the floor.",
                "Extend arms parallel to the floor, right arm forward and left arm back; gaze over your right hand.",
                "Keep hips open to the long edge of the mat and shoulders directly over the pelvis.",
                "Hold for 5–8 breaths and switch sides."
            ],
            benefits: [
                "Tones legs and opens hips",
                "Strengthens core and arms",
                "Cultivates focus and inner strength"
            ],
            contraindications: [
                "Knee injuries — do not bend beyond 90 degrees",
                "Neck issues — keep gaze neutral rather than turning the head"
            ],
            defaultHoldDurationSeconds: 45,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Use a chair under the front thigh for support in the third trimester."
            ),
            muscleGroups: ["Quadriceps", "Inner thighs", "Glutes", "Core", "Shoulders"]
        ),

        // 4. Warrior III
        YogaPose(
            id: "warrior-iii",
            name: "Warrior III",
            sanskritName: "Virabhadrasana III",
            instructions: [
                "Begin in Mountain Pose; shift weight onto your right foot.",
                "Hinge forward at the hip, extending the left leg behind you until the body forms a T shape.",
                "Flex the lifted foot and keep both hips level.",
                "Extend arms forward alongside the ears, or place hands on hips for stability.",
                "Hold 3–5 breaths, then step the foot back down and switch sides."
            ],
            benefits: [
                "Builds full-body balance and proprioception",
                "Strengthens standing leg, glutes, and back",
                "Sharpens concentration and mental focus"
            ],
            contraindications: [
                "Ankle or knee instability — practice near a wall",
                "Vertigo — use a chair or skip the pose"
            ],
            defaultHoldDurationSeconds: 30,
            difficulty: .intermediate,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "Use a wall or chair for balance support from the second trimester onward. Avoid in the third trimester due to balance demands."
            ),
            muscleGroups: ["Hamstrings", "Glutes", "Core", "Upper back", "Shoulders"]
        ),

        // 5. Triangle Pose
        YogaPose(
            id: "triangle-pose",
            name: "Triangle Pose",
            sanskritName: "Trikonasana",
            instructions: [
                "Stand with feet 3–4 feet apart; turn the right foot out 90 degrees and the left foot in 15 degrees.",
                "Extend arms out at shoulder height and lean to the right, hinging from the hip.",
                "Rest the right hand on the shin, a block, or the floor; extend the left arm to the ceiling.",
                "Stack hips and shoulders in one vertical plane; gaze up at the raised hand or forward if the neck is sensitive.",
                "Hold 5 breaths each side."
            ],
            benefits: [
                "Stretches the inner thighs, hamstrings, and spine",
                "Strengthens legs and obliques",
                "Relieves lower back tension"
            ],
            contraindications: [
                "Low blood pressure — rise slowly",
                "Neck issues — keep gaze neutral"
            ],
            defaultHoldDurationSeconds: 40,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Rest the lower hand on a block or the shin rather than the floor to avoid compressing the belly."
            ),
            muscleGroups: ["Inner thighs", "Hamstrings", "Obliques", "Spine"]
        ),

        // 6. Tree Pose
        YogaPose(
            id: "tree-pose",
            name: "Tree Pose",
            sanskritName: "Vrksasana",
            instructions: [
                "Stand in Mountain Pose; shift weight onto the right foot.",
                "Place the left foot on the inner right calf or inner right thigh — avoid placing it on the knee joint.",
                "Bring palms together at the heart or raise arms overhead like branches.",
                "Fix your gaze (drishti) on a still point to help maintain balance.",
                "Hold 5–8 breaths and switch sides."
            ],
            benefits: [
                "Improves single-leg balance and ankle stability",
                "Strengthens the standing leg and core",
                "Promotes focus and calm"
            ],
            contraindications: [
                "Balance disorders — practice with one hand on a wall"
            ],
            defaultHoldDurationSeconds: 40,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Stand near a wall or use a chair for support as the center of gravity shifts in the third trimester."
            ),
            muscleGroups: ["Quadriceps", "Glutes", "Core", "Ankles"]
        ),

        // 7. Chair Pose
        YogaPose(
            id: "chair-pose",
            name: "Chair Pose",
            sanskritName: "Utkatasana",
            instructions: [
                "Stand with feet together or hip-width apart; inhale and raise arms overhead.",
                "Exhale and sit back and down as if lowering onto an imaginary chair, keeping knees over toes.",
                "Bring thighs as parallel to the floor as comfortable while keeping the torso upright.",
                "Draw the lower ribs in to prevent the lower back from over-arching.",
                "Hold 5–8 breaths, then inhale to stand."
            ],
            benefits: [
                "Strengthens quadriceps, glutes, and core",
                "Builds heat and stamina",
                "Tones the ankles and calves"
            ],
            contraindications: [
                "Knee pain — keep a smaller range of motion",
                "Low back injury — maintain a neutral spine throughout"
            ],
            defaultHoldDurationSeconds: 30,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Use a wall behind you for support and avoid squatting deeper than is comfortable."
            ),
            muscleGroups: ["Quadriceps", "Glutes", "Core", "Calves"]
        ),

        // 8. Extended Side Angle
        YogaPose(
            id: "extended-side-angle",
            name: "Extended Side Angle",
            sanskritName: "Utthita Parsvakonasana",
            instructions: [
                "Begin in Warrior II with the right knee bent.",
                "Lower the right forearm to the right thigh or place the right hand on a block outside the right foot.",
                "Extend the left arm over the left ear, creating one long line from the left heel to the left fingertips.",
                "Press the right knee into the right arm and open the chest toward the ceiling.",
                "Hold 5 breaths each side."
            ],
            benefits: [
                "Deeply stretches the side body and inner groin",
                "Strengthens legs and obliques",
                "Improves spinal mobility"
            ],
            contraindications: [
                "Neck problems — keep gaze forward rather than up"
            ],
            defaultHoldDurationSeconds: 40,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Rest the forearm on the thigh rather than reaching to the floor to give the belly room."
            ),
            muscleGroups: ["Inner thighs", "Obliques", "Quadriceps", "Side body"]
        ),

        // 9. Standing Forward Fold
        YogaPose(
            id: "standing-forward-fold",
            name: "Standing Forward Fold",
            sanskritName: "Uttanasana",
            instructions: [
                "Stand in Mountain Pose with feet hip-width apart.",
                "Exhale and hinge forward from the hips, bending the knees slightly if the hamstrings are tight.",
                "Let the crown of the head hang heavy toward the floor and grab opposite elbows if desired.",
                "Shift weight slightly forward into the balls of the feet to lengthen the back of the legs.",
                "Hold 5–10 breaths, then bend the knees and slowly rise."
            ],
            benefits: [
                "Releases tension in the hamstrings and lower back",
                "Calms the nervous system and reduces anxiety",
                "Gently decompresses the spine"
            ],
            contraindications: [
                "Hamstring tears — bend knees generously",
                "Glaucoma or high blood pressure — keep the head level with the hips or above"
            ],
            defaultHoldDurationSeconds: 45,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Use wide-leg variation and rest hands on blocks to accommodate the growing belly."
            ),
            muscleGroups: ["Hamstrings", "Lower back", "Calves"]
        ),

        // 10. Goddess Pose
        YogaPose(
            id: "goddess-pose",
            name: "Goddess Pose",
            sanskritName: "Utkata Konasana",
            instructions: [
                "Step feet wide apart, turning toes out 45 degrees.",
                "Bend both knees and lower the hips toward knee height, keeping knees tracking over toes.",
                "Raise arms to shoulder height and bend elbows 90 degrees, palms facing forward.",
                "Draw the shoulder blades together and lift the chest; keep the core gently engaged.",
                "Hold 5–8 breaths."
            ],
            benefits: [
                "Opens the hips and inner thighs",
                "Strengthens legs and pelvic floor",
                "Builds warming energy and confidence"
            ],
            contraindications: [
                "Hip or knee injuries — reduce depth of squat"
            ],
            defaultHoldDurationSeconds: 40,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .safe,
                postpartum: .safe,
                notes: "An excellent prenatal pose; keep the squat shallow in the third trimester and hold a chair for support."
            ),
            muscleGroups: ["Inner thighs", "Quadriceps", "Glutes", "Pelvic floor"]
        ),

        // 11. Wide-Legged Forward Fold
        YogaPose(
            id: "wide-legged-forward-fold",
            name: "Wide-Legged Forward Fold",
            sanskritName: "Prasarita Padottanasana",
            instructions: [
                "Stand with feet parallel and about 4 feet apart.",
                "Place hands on hips; inhale to lift the chest, then exhale and hinge forward from the hips.",
                "Place hands on the floor, blocks, or clasp them behind the back for a shoulder opener.",
                "Keep the legs active and feet pressing firmly into the floor.",
                "Hold 5–8 breaths, then lift back to standing using the hip flexors."
            ],
            benefits: [
                "Stretches inner thighs, hamstrings, and spine",
                "Calms an overactive mind",
                "Relieves lower back fatigue"
            ],
            contraindications: [
                "Hamstring injuries — keep knees bent",
                "Avoid full inversion if experiencing heartburn"
            ],
            defaultHoldDurationSeconds: 45,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Place hands on blocks and keep the fold at hip height rather than fully inverting."
            ),
            muscleGroups: ["Inner thighs", "Hamstrings", "Lower back", "Calves"]
        ),

        // 12. Pyramid Pose
        YogaPose(
            id: "pyramid-pose",
            name: "Pyramid Pose",
            sanskritName: "Parsvottanasana",
            instructions: [
                "From Mountain Pose, step the right foot back about 2.5–3 feet, turning it out slightly; both hips face forward.",
                "Place hands on hips or blocks on either side of the front foot.",
                "Inhale to lengthen the spine; exhale and fold forward over the left leg, keeping it straight.",
                "Draw the front hip back and the rear hip forward to keep the hips square.",
                "Hold 5 breaths each side."
            ],
            benefits: [
                "Deeply stretches the hamstrings and calves",
                "Improves hip alignment and posture",
                "Strengthens the legs and challenges balance"
            ],
            contraindications: [
                "Hamstring strains — keep a slight bend in the front knee"
            ],
            defaultHoldDurationSeconds: 40,
            difficulty: .intermediate,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Use blocks under the hands to keep the fold gentle; widen the stance for balance stability."
            ),
            muscleGroups: ["Hamstrings", "Calves", "Glutes", "Core"]
        )
    ]

    // MARK: - Seated Poses (10)

    private static let seated: [YogaPose] = [

        // 13. Seated Forward Fold
        YogaPose(
            id: "seated-forward-fold",
            name: "Seated Forward Fold",
            sanskritName: "Paschimottanasana",
            instructions: [
                "Sit on the floor with legs extended straight in front of you (Staff Pose).",
                "Flex your feet and press the thighs toward the floor.",
                "Inhale to lengthen the spine; exhale and hinge forward from the hips, reaching for the shins, ankles, or feet.",
                "Keep the back as long as possible rather than rounding aggressively.",
                "Hold 5–10 breaths."
            ],
            benefits: [
                "Stretches the entire posterior chain — hamstrings, calves, and back",
                "Stimulates the digestive organs and relieves bloating",
                "Promotes introspection and calm"
            ],
            contraindications: [
                "Lower back injuries — bend knees and prioritise length over depth",
                "Sciatica — sit on a folded blanket to tilt the pelvis forward"
            ],
            defaultHoldDurationSeconds: 60,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Widen the legs into a V-shape to give the belly space; use a strap around the feet."
            ),
            muscleGroups: ["Hamstrings", "Lower back", "Calves", "Spine"]
        ),

        // 14. Butterfly / Bound Angle Pose
        YogaPose(
            id: "butterfly-pose",
            name: "Butterfly Pose",
            sanskritName: "Baddha Konasana",
            instructions: [
                "Sit tall with legs extended, then bend both knees and bring the soles of the feet together.",
                "Interlace fingers around the feet and draw the heels as close to the pelvis as comfortable.",
                "Sit on the front of the sit bones, lengthening the spine upright.",
                "Optionally fold forward over the feet for a deeper stretch.",
                "Hold 1–3 minutes."
            ],
            benefits: [
                "Opens the inner thighs and groins",
                "Stimulates the ovaries and reproductive organs",
                "Soothes menstrual discomfort and anxiety"
            ],
            contraindications: [
                "Knee injuries — support the thighs with blocks or blankets"
            ],
            defaultHoldDurationSeconds: 90,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .safe,
                postpartum: .safe,
                notes: "One of the best prenatal poses; support the thighs with blocks if they don't reach the floor."
            ),
            muscleGroups: ["Inner thighs", "Groins", "Hip flexors"]
        ),

        // 15. Head-to-Knee Pose
        YogaPose(
            id: "head-to-knee-pose",
            name: "Head-to-Knee Pose",
            sanskritName: "Janu Sirsasana",
            instructions: [
                "Sit with legs extended; bend the right knee and place the right foot against the inner left thigh.",
                "Inhale to grow tall; exhale and rotate toward the extended left leg.",
                "Fold forward over the left leg, holding the foot, ankle, or shin.",
                "Keep the extended leg active and the foot flexed.",
                "Hold 5–8 breaths each side."
            ],
            benefits: [
                "Stretches the hamstrings and inner thighs with a mild twist",
                "Calms the nervous system and reduces anxiety",
                "Relieves mild lower back tension"
            ],
            contraindications: [
                "Knee injury — place a folded blanket under the bent knee"
            ],
            defaultHoldDurationSeconds: 60,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Open the legs wider and use a strap to avoid compressing the abdomen."
            ),
            muscleGroups: ["Hamstrings", "Inner thighs", "Lower back"]
        ),

        // 16. Seated Spinal Twist
        YogaPose(
            id: "seated-spinal-twist",
            name: "Seated Spinal Twist",
            sanskritName: "Ardha Matsyendrasana",
            instructions: [
                "Sit with legs extended; bend the right knee and cross the right foot over the left thigh, placing it flat on the floor.",
                "Option: keep the left leg straight or bend it so the left foot rests near the right hip.",
                "On an inhale, lengthen the spine; on an exhale, twist to the right, placing the right hand on the floor behind you.",
                "Wrap the left arm around the right knee or press the elbow against the knee.",
                "Hold 5 breaths each side."
            ],
            benefits: [
                "Promotes spinal rotation and mobility",
                "Stimulates digestion and reduces bloating",
                "Relieves tension in the back and hips"
            ],
            contraindications: [
                "Avoid deep twists during pregnancy",
                "Spinal disc issues — rotate only as far as comfortable"
            ],
            defaultHoldDurationSeconds: 45,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .modified,
                trimester2: .avoid,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "In the first trimester use only open twists; avoid closed-belly twists from the second trimester onward."
            ),
            muscleGroups: ["Spine", "Obliques", "Hips", "Outer glutes"]
        ),

        // 17. Hero Pose
        YogaPose(
            id: "hero-pose",
            name: "Hero Pose",
            sanskritName: "Virasana",
            instructions: [
                "Kneel on the floor with knees together and feet slightly wider than hip-width.",
                "Lower your seat between your feet, or sit on a block if this is uncomfortable.",
                "Sit tall with hands resting on thighs; press the tops of the feet into the floor.",
                "Lengthen through the spine and breathe deeply.",
                "Hold 1–3 minutes."
            ],
            benefits: [
                "Deeply stretches the quadriceps and ankles",
                "Improves posture and internal rotation of the hips",
                "Creates a calming, stable seated position"
            ],
            contraindications: [
                "Knee injuries — sit on a tall block or skip the pose",
                "Ankle pain — roll a blanket under the ankles"
            ],
            defaultHoldDurationSeconds: 90,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Sit on a block or bolster as the belly grows; avoid if circulation to the legs is impaired."
            ),
            muscleGroups: ["Quadriceps", "Ankles", "Knee ligaments"]
        ),

        // 18. Staff Pose
        YogaPose(
            id: "staff-pose",
            name: "Staff Pose",
            sanskritName: "Dandasana",
            instructions: [
                "Sit on the floor with legs extended straight, feet together and flexed.",
                "Press the palms or fingertips into the floor beside the hips.",
                "Lift through the chest, draw the shoulders back and down.",
                "Engage the thighs and press the backs of the knees toward the floor.",
                "Hold 5–10 breaths as a transitional or foundation pose."
            ],
            benefits: [
                "Strengthens the core and back muscles",
                "Establishes proper seated alignment",
                "Gently stretches the hamstrings"
            ],
            contraindications: [
                "Tight hamstrings — sit on a folded blanket"
            ],
            defaultHoldDurationSeconds: 30,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Core", "Back extensors", "Hamstrings"]
        ),

        // 19. Easy Pose
        YogaPose(
            id: "easy-pose",
            name: "Easy Pose",
            sanskritName: "Sukhasana",
            instructions: [
                "Sit cross-legged on the floor or on a folded blanket, with each foot below the opposite knee.",
                "Rest hands on the knees, palms up for openness or down for grounding.",
                "Lengthen the spine upward; let the outer thighs soften toward the floor.",
                "Close the eyes and breathe naturally.",
                "Hold as long as comfortable during meditation or breathing practices."
            ],
            benefits: [
                "Creates a stable, comfortable foundation for meditation",
                "Gently opens the hips and inner thighs",
                "Encourages mindful breathing and relaxation"
            ],
            contraindications: [
                "Knee or hip discomfort — sit in a chair or on a higher support"
            ],
            defaultHoldDurationSeconds: 120,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Hip flexors", "Inner thighs", "Spine"]
        ),

        // 20. Seated Pigeon (Eye of the Needle — floor version)
        YogaPose(
            id: "seated-pigeon",
            name: "Seated Pigeon",
            sanskritName: "Kapotasana (variation)",
            instructions: [
                "Sit upright in a chair or on the floor with both knees bent and feet flat.",
                "Cross the right ankle over the left knee, flexing the right foot.",
                "Keeping the spine long, hinge forward slightly from the hips until a stretch is felt in the outer right hip.",
                "Rest hands on the shin or hold the ankle.",
                "Hold 60 seconds and switch sides."
            ],
            benefits: [
                "Releases tension in the piriformis and outer hip",
                "Relieves sciatic nerve discomfort",
                "Safe hip opener accessible from a chair"
            ],
            contraindications: [
                "Recent hip replacement — skip this pose"
            ],
            defaultHoldDurationSeconds: 60,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .safe,
                postpartum: .safe,
                notes: "The chair variation is ideal throughout all trimesters; avoid lying-down versions."
            ),
            muscleGroups: ["Piriformis", "Outer hip", "Glutes", "Hip rotators"]
        ),

        // 21. Wide-Angle Seated Forward Fold
        YogaPose(
            id: "wide-angle-seated-forward-fold",
            name: "Wide-Angle Seated Forward Fold",
            sanskritName: "Upavistha Konasana",
            instructions: [
                "Sit on the floor and open the legs wide into a V-shape.",
                "Flex the feet and press the backs of the knees toward the floor.",
                "Inhale to lengthen the spine; exhale and walk the hands forward between the legs.",
                "Aim to fold the torso forward rather than rounding the back.",
                "Hold 1–2 minutes."
            ],
            benefits: [
                "Deeply opens the inner thighs and groins",
                "Stretches the hamstrings and lower back",
                "Stimulates the abdominal organs and can ease menstrual discomfort"
            ],
            contraindications: [
                "Hamstring injury — keep knees bent slightly"
            ],
            defaultHoldDurationSeconds: 90,
            difficulty: .intermediate,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Walk hands forward only until the belly is comfortable; do not compress the abdomen."
            ),
            muscleGroups: ["Inner thighs", "Hamstrings", "Groins", "Lower back"]
        ),

        // 22. Fire Log Pose
        YogaPose(
            id: "fire-log-pose",
            name: "Fire Log Pose",
            sanskritName: "Agnistambhasana",
            instructions: [
                "Sit cross-legged; slide the right shin so it is parallel to the front of the mat.",
                "Stack the left shin on top of the right so the left ankle rests on the right knee.",
                "Flex both feet to protect the knee joints.",
                "Sit upright or fold gently forward, walking the hands in front.",
                "Hold 1–2 minutes each side."
            ],
            benefits: [
                "Intensely opens the outer hips and groins",
                "Releases deep gluteal and piriformis tension",
                "Relieves sciatic discomfort"
            ],
            contraindications: [
                "Knee injuries — use Seated Pigeon instead",
                "Tight hips — place a block under the top knee"
            ],
            defaultHoldDurationSeconds: 90,
            difficulty: .intermediate,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Sit on a folded blanket and keep the torso upright rather than folding in the later trimesters."
            ),
            muscleGroups: ["Outer hips", "Piriformis", "Groins", "Inner thighs"]
        )
    ]

    // MARK: - Floor / Supine Poses (8)

    private static let floorSupine: [YogaPose] = [

        // 23. Bridge Pose
        YogaPose(
            id: "bridge-pose",
            name: "Bridge Pose",
            sanskritName: "Setu Bandha Sarvangasana",
            instructions: [
                "Lie on your back with knees bent, feet flat on the floor hip-width apart, heels close to the sit bones.",
                "Rest arms alongside the body, palms facing down.",
                "Inhale; press the feet and arms into the floor and lift the hips toward the ceiling.",
                "Optionally interlace the fingers under the back and roll the shoulders under.",
                "Hold 5–10 breaths, then lower vertebra by vertebra."
            ],
            benefits: [
                "Strengthens glutes, hamstrings, and lower back",
                "Opens the chest and hip flexors",
                "Mildly stimulates the thyroid and calms the mind"
            ],
            contraindications: [
                "Neck injuries — do not turn the head while in the pose"
            ],
            defaultHoldDurationSeconds: 45,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Limit to 60-second holds in the second trimester and use a bolster under the sacrum for a supported version in the third trimester."
            ),
            muscleGroups: ["Glutes", "Hamstrings", "Lower back", "Hip flexors"]
        ),

        // 24. Happy Baby Pose
        YogaPose(
            id: "happy-baby-pose",
            name: "Happy Baby Pose",
            sanskritName: "Ananda Balasana",
            instructions: [
                "Lie on your back and draw both knees into the chest.",
                "Open the knees wider than the torso and bring them toward the armpits.",
                "Hold the outer edges of the feet (or ankles) with each hand.",
                "Flex the feet toward the ceiling and gently draw the knees toward the floor.",
                "Rock side to side to massage the lower back; hold 1–2 minutes."
            ],
            benefits: [
                "Releases the lower back and sacrum",
                "Opens the inner groins and inner thighs",
                "Calming and playful — great for stress relief"
            ],
            contraindications: [
                "Pregnancy beyond 12 weeks — omit or use a side-lying variation"
            ],
            defaultHoldDurationSeconds: 90,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .avoid,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "Lying flat on the back is contraindicated after the first trimester; substitute with supported side-lying or reclined butterfly."
            ),
            muscleGroups: ["Inner groins", "Lower back", "Sacrum", "Hip flexors"]
        ),

        // 25. Supine Spinal Twist
        YogaPose(
            id: "supine-spinal-twist",
            name: "Supine Spinal Twist",
            sanskritName: "Supta Matsyendrasana",
            instructions: [
                "Lie on your back; draw the right knee into the chest.",
                "With the left hand, gently guide the right knee across the body toward the left side of the mat.",
                "Extend the right arm out at shoulder height, palm facing up; gaze right if comfortable.",
                "Both shoulders remain grounded on the floor.",
                "Hold 1–2 minutes each side."
            ],
            benefits: [
                "Releases tension across the lower back and hips",
                "Encourages gentle spinal rotation and decompression",
                "Activates the parasympathetic nervous system"
            ],
            contraindications: [
                "Avoid closed twists during pregnancy"
            ],
            defaultHoldDurationSeconds: 90,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .modified,
                trimester2: .avoid,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "In the first trimester use a very gentle, open twist; avoid from the second trimester onward."
            ),
            muscleGroups: ["Lower back", "Glutes", "Obliques", "Spine"]
        ),

        // 26. Legs Up the Wall
        YogaPose(
            id: "legs-up-the-wall",
            name: "Legs Up the Wall",
            sanskritName: "Viparita Karani",
            instructions: [
                "Sit sideways close to a wall; swing the legs up as you lower the back to the floor.",
                "Shimmy the sit bones as close to the baseboard as is comfortable.",
                "Rest arms alongside the body, palms up, and close the eyes.",
                "Breathe naturally and allow the legs to soften.",
                "Hold 5–15 minutes."
            ],
            benefits: [
                "Reduces swelling and fatigue in the legs and feet",
                "Calms the nervous system and lowers cortisol",
                "Gently stretches the hamstrings without effort"
            ],
            contraindications: [
                "Glaucoma — skip or elevate the head slightly",
                "Severe varicose veins — consult a physician first"
            ],
            defaultHoldDurationSeconds: 300,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "After week 20 avoid lying flat; use a supported incline with a bolster under the back instead."
            ),
            muscleGroups: ["Hamstrings", "Lower back", "Nervous system"]
        ),

        // 27. Reclined Butterfly
        YogaPose(
            id: "reclined-butterfly",
            name: "Reclined Butterfly",
            sanskritName: "Supta Baddha Konasana",
            instructions: [
                "Lie on your back with knees bent; bring the soles of the feet together and let the knees fall open.",
                "Support each knee with a block or folded blanket if needed.",
                "Rest arms alongside the body, palms facing up.",
                "Allow gravity to open the inner thighs and breathe into the belly.",
                "Hold 3–10 minutes."
            ],
            benefits: [
                "Opens the inner thighs and groins passively",
                "Deeply relaxing for the nervous system",
                "Soothes PMS, menstrual cramps, and anxiety"
            ],
            contraindications: [
                "Pregnancy beyond 20 weeks — use an incline bolster under the back"
            ],
            defaultHoldDurationSeconds: 180,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Prop the torso on a bolster at a 30-degree incline from the second trimester to avoid the supine position."
            ),
            muscleGroups: ["Inner thighs", "Groins", "Hip flexors"]
        ),

        // 28. Corpse Pose / Savasana
        YogaPose(
            id: "savasana",
            name: "Savasana",
            sanskritName: "Savasana",
            instructions: [
                "Lie flat on your back with legs extended and slightly wider than hip-width.",
                "Let the feet fall open naturally; rest arms alongside the body, palms up.",
                "Close the eyes and release all muscular effort.",
                "Breathe naturally and allow the body and mind to integrate the practice.",
                "Rest for 5–20 minutes."
            ],
            benefits: [
                "Allows the nervous system to consolidate the benefits of practice",
                "Reduces blood pressure and cortisol",
                "Promotes deep rest and mental clarity"
            ],
            contraindications: [
                "Pregnancy beyond 20 weeks — use left-side-lying or a bolster incline"
            ],
            defaultHoldDurationSeconds: 300,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "From the second trimester use a bolster at a 30-degree angle or take Side-Lying Savasana."
            ),
            muscleGroups: ["Full body relaxation"]
        ),

        // 29. Knees-to-Chest
        YogaPose(
            id: "knees-to-chest",
            name: "Knees-to-Chest Pose",
            sanskritName: "Apanasana",
            instructions: [
                "Lie on your back; draw both knees into the chest and wrap the arms around the shins.",
                "Rock gently side to side to massage the lower back.",
                "Optionally make slow circles with the knees to release the sacrum.",
                "Keep the shoulders and head relaxed on the floor.",
                "Hold 1–2 minutes."
            ],
            benefits: [
                "Relieves lower back ache and sacral tension",
                "Aids digestion and releases intestinal gas",
                "Gently stimulates the colon"
            ],
            contraindications: [
                "Pregnancy — switch to single-knee-to-chest to avoid compressing the belly"
            ],
            defaultHoldDurationSeconds: 60,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "From the second trimester perform one knee at a time to keep the belly free."
            ),
            muscleGroups: ["Lower back", "Glutes", "Sacrum"]
        ),

        // 30. Figure 4 Stretch (Supine Pigeon)
        YogaPose(
            id: "figure-four-stretch",
            name: "Figure 4 Stretch",
            sanskritName: "Supta Kapotasana",
            instructions: [
                "Lie on your back with knees bent and feet flat on the floor.",
                "Cross the right ankle over the left thigh just below the knee; flex the right foot.",
                "Thread the right arm through the gap between the legs and interlace fingers behind the left thigh.",
                "Draw the legs gently toward the chest until you feel a stretch in the right outer hip.",
                "Hold 60–90 seconds each side."
            ],
            benefits: [
                "Targets the piriformis and outer hip without spinal loading",
                "Relieves sciatic nerve tension",
                "Beginner-friendly alternative to Pigeon Pose"
            ],
            contraindications: [
                "Knee pain — keep the ankle on the thigh (not the shin) and flex the foot firmly"
            ],
            defaultHoldDurationSeconds: 75,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "From the second trimester substitute with the seated chair variation (Seated Pigeon)."
            ),
            muscleGroups: ["Piriformis", "Outer hip", "Glutes", "Hip rotators"]
        )
    ]

    // MARK: - Hands & Knees Poses (6)

    private static let handsAndKnees: [YogaPose] = [

        // 31. Cat-Cow
        YogaPose(
            id: "cat-cow",
            name: "Cat-Cow",
            sanskritName: "Marjaryasana-Bitilasana",
            instructions: [
                "Begin on hands and knees in Tabletop with wrists under shoulders and knees under hips.",
                "Inhale: drop the belly, lift the tailbone and chest into Cow — gaze gently forward.",
                "Exhale: round the spine toward the ceiling, tuck the tailbone, and drop the head — this is Cat.",
                "Move slowly and fluidly, synchronising each movement with the breath.",
                "Continue for 1–3 minutes."
            ],
            benefits: [
                "Mobilises the entire spine and relieves back ache",
                "Coordinates breath and movement for mindful awareness",
                "Gently massages the abdominal organs and digestive system"
            ],
            contraindications: [
                "Wrist injuries — perform on fists or forearms"
            ],
            defaultHoldDurationSeconds: 60,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Spine", "Abdominals", "Back extensors"]
        ),

        // 32. Bird-Dog
        YogaPose(
            id: "bird-dog",
            name: "Bird-Dog",
            sanskritName: nil,
            instructions: [
                "From Tabletop, engage the core and keep the spine neutral.",
                "Extend the right arm forward and the left leg back simultaneously.",
                "Both limbs remain parallel to the floor; hips stay level.",
                "Hold 5 breaths, then switch sides. Perform 3–5 rounds per side."
            ],
            benefits: [
                "Builds core stability and cross-body coordination",
                "Strengthens the back extensors, glutes, and shoulders",
                "Low-impact alternative to plank-based core work"
            ],
            contraindications: [
                "Wrist pain — use forearm variation on elbows and knees"
            ],
            defaultHoldDurationSeconds: 30,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .safe,
                postpartum: .safe,
                notes: "An excellent prenatal core exercise; avoid if wrists are sore — use forearm modification."
            ),
            muscleGroups: ["Core", "Glutes", "Back extensors", "Shoulders"]
        ),

        // 33. Thread the Needle
        YogaPose(
            id: "thread-the-needle",
            name: "Thread the Needle",
            sanskritName: "Parsva Balasana",
            instructions: [
                "From Tabletop, slide the right arm under the left arm along the floor.",
                "Lower the right shoulder and right temple to the floor; hips remain high.",
                "The left arm can stay propped or extend forward.",
                "Feel a gentle rotation through the thoracic spine.",
                "Hold 5–8 breaths each side."
            ],
            benefits: [
                "Opens the thoracic spine and shoulders",
                "Relieves upper back and neck tension",
                "Provides a gentle twist without abdominal compression"
            ],
            contraindications: [
                "Shoulder injuries — modify the depth of the slide"
            ],
            defaultHoldDurationSeconds: 45,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Keep the rotation gentle and use a blanket under the shoulder for comfort."
            ),
            muscleGroups: ["Thoracic spine", "Shoulders", "Upper back"]
        ),

        // 34. Puppy Pose
        YogaPose(
            id: "puppy-pose",
            name: "Puppy Pose",
            sanskritName: "Uttana Shishosana",
            instructions: [
                "Begin in Tabletop; walk the hands forward while keeping hips over knees.",
                "Lower the chest and forehead toward the floor, arms extended.",
                "Press the palms into the floor and allow the chest to melt down.",
                "Keep hips stacked over the knees and breathe into the upper back.",
                "Hold 5–10 breaths."
            ],
            benefits: [
                "Stretches the spine, chest, and shoulders",
                "Opens the upper back and relieves tension between the shoulder blades",
                "Gentle heart opener suitable for all levels"
            ],
            contraindications: [
                "Knee discomfort — place a folded blanket under the knees"
            ],
            defaultHoldDurationSeconds: 45,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .safe,
                postpartum: .safe,
                notes: "Excellent for relieving upper back tension in pregnancy; widen the knees to accommodate the belly."
            ),
            muscleGroups: ["Spine", "Chest", "Shoulders", "Upper back"]
        ),

        // 35. Child's Pose
        YogaPose(
            id: "childs-pose",
            name: "Child's Pose",
            sanskritName: "Balasana",
            instructions: [
                "From kneeling, sink the hips back toward the heels.",
                "Extend the arms forward on the floor (Extended Child's Pose) or alongside the body.",
                "Rest the forehead on the floor or a block.",
                "Breathe into the back body, expanding the ribs with each inhale.",
                "Hold as long as needed — typically 1–5 minutes."
            ],
            benefits: [
                "Gently decompresses the lower back and hips",
                "Signals safety to the nervous system, inducing rest",
                "Relieves fatigue, anxiety, and mild headaches"
            ],
            contraindications: [
                "Knee injuries — place a rolled blanket behind the knees",
                "Pregnant — widen the knees significantly"
            ],
            defaultHoldDurationSeconds: 120,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Widen the knees wide enough that the belly rests between the thighs; use a bolster under the torso for support."
            ),
            muscleGroups: ["Lower back", "Hips", "Thighs", "Ankles"]
        ),

        // 36. Tabletop
        YogaPose(
            id: "tabletop",
            name: "Tabletop Pose",
            sanskritName: "Bharmanasana",
            instructions: [
                "Come to hands and knees; position wrists directly under shoulders and knees under hips.",
                "Spread the fingers wide and press all ten fingertips into the floor.",
                "Keep the spine neutral — neither arched nor rounded.",
                "Draw the lower belly in gently and breathe steadily.",
                "Use as the starting position for other hands-and-knees poses."
            ],
            benefits: [
                "Establishes a neutral spine and core engagement",
                "Distributes weight safely across the wrists",
                "Foundation for Cat-Cow, Bird-Dog, and other poses"
            ],
            contraindications: [
                "Wrist pain — use fists or forearm support"
            ],
            defaultHoldDurationSeconds: 20,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Core", "Wrists", "Shoulders"]
        )
    ]

    // MARK: - Balance Poses (4)

    private static let balance: [YogaPose] = [

        // 37. Eagle Pose
        YogaPose(
            id: "eagle-pose",
            name: "Eagle Pose",
            sanskritName: "Garudasana",
            instructions: [
                "Stand in Mountain Pose; bend both knees slightly, shift weight to the left foot.",
                "Lift the right leg and cross it over the left thigh; hook the right foot behind the left calf if possible.",
                "Extend both arms forward at shoulder height, cross the left arm over the right and bend elbows, wrapping forearms so palms press together.",
                "Lift elbows to shoulder height and breathe into the upper back.",
                "Hold 5 breaths, then release and switch sides."
            ],
            benefits: [
                "Strengthens ankles, calves, and thighs",
                "Stretches the upper back, shoulders, and outer hips",
                "Improves balance and concentration"
            ],
            contraindications: [
                "Knee injuries — avoid crossing the leg; stand in Mountain Pose with arms only"
            ],
            defaultHoldDurationSeconds: 35,
            difficulty: .intermediate,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "Avoid deep leg crossing and standing balance from the third trimester; use the arm position seated instead."
            ),
            muscleGroups: ["Ankles", "Outer hips", "Upper back", "Shoulders", "Core"]
        ),

        // 38. Dancer's Pose
        YogaPose(
            id: "dancers-pose",
            name: "Dancer's Pose",
            sanskritName: "Natarajasana",
            instructions: [
                "Stand in Mountain Pose; shift weight to the right foot.",
                "Bend the left knee, reach back with the left hand and hold the inner left ankle or foot.",
                "Extend the right arm forward at shoulder height for balance; set your gaze on a fixed point.",
                "Begin to kick the left foot into the hand, lifting the leg behind you as you hinge the torso slightly forward.",
                "Hold 3–5 breaths each side."
            ],
            benefits: [
                "Deeply stretches the quadriceps and hip flexors",
                "Strengthens the standing leg, back, and core",
                "Cultivates balance, grace, and focus"
            ],
            contraindications: [
                "Low blood pressure — keep the torso more upright",
                "Avoid during pregnancy — balance and backbend are not appropriate"
            ],
            defaultHoldDurationSeconds: 30,
            difficulty: .intermediate,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .modified,
                trimester2: .avoid,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "Avoid from the second trimester due to balance demands and backbend; use a chair for the quad stretch instead."
            ),
            muscleGroups: ["Quadriceps", "Hip flexors", "Core", "Back extensors", "Shoulders"]
        ),

        // 39. Half Moon Pose
        YogaPose(
            id: "half-moon-pose",
            name: "Half Moon Pose",
            sanskritName: "Ardha Chandrasana",
            instructions: [
                "From Triangle Pose, bend the front knee and walk the hand forward about 12 inches, placing it on a block or the floor.",
                "Shift weight onto the right foot and right hand; lift the left leg parallel to the floor.",
                "Stack the left hip over the right; extend the top arm toward the ceiling.",
                "Gaze forward or up toward the raised hand.",
                "Hold 3–5 breaths each side."
            ],
            benefits: [
                "Builds single-leg balance and body coordination",
                "Strengthens the standing leg, glutes, and core",
                "Opens the chest and groins"
            ],
            contraindications: [
                "Pregnancy from second trimester — use a wall for support or skip the pose"
            ],
            defaultHoldDurationSeconds: 30,
            difficulty: .intermediate,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "Practice against a wall for support in the second trimester; avoid in the third trimester."
            ),
            muscleGroups: ["Glutes", "Core", "Inner thighs", "Hamstrings", "Shoulders"]
        ),

        // 40. Standing Hand-to-Big-Toe Pose
        YogaPose(
            id: "standing-hand-to-big-toe",
            name: "Standing Hand-to-Big-Toe Pose",
            sanskritName: "Utthita Hasta Padangusthasana",
            instructions: [
                "Stand in Mountain Pose; shift weight to the left foot.",
                "Bend the right knee and hold the right big toe with the index and middle fingers of the right hand.",
                "Extend the right leg forward, straightening as much as possible; keep the standing leg strong.",
                "Option: extend the leg to the side for a hip-opening variation.",
                "Hold 5 breaths each side."
            ],
            benefits: [
                "Stretches the hamstrings and inner thighs",
                "Strengthens the standing leg and ankle",
                "Improves balance and hip flexibility"
            ],
            contraindications: [
                "Hamstring strains — keep knee bent and use a strap around the foot"
            ],
            defaultHoldDurationSeconds: 35,
            difficulty: .advanced,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "Keep the knee bent and use a wall for balance; avoid from the third trimester."
            ),
            muscleGroups: ["Hamstrings", "Inner thighs", "Core", "Ankles"]
        )
    ]

    // MARK: - Gentle / Restorative Poses (6)

    private static let restorative: [YogaPose] = [

        // 41. Supported Fish Pose
        YogaPose(
            id: "supported-fish-pose",
            name: "Supported Fish Pose",
            sanskritName: "Matsyasana (supported)",
            instructions: [
                "Place a bolster or rolled blanket perpendicular to your spine, positioned at mid-back height.",
                "Sit in front of the support, then gently lower the back onto it.",
                "Extend legs straight or bend the knees with feet flat on the floor.",
                "Rest arms at 45 degrees, palms facing up; close the eyes.",
                "Hold 5–10 minutes."
            ],
            benefits: [
                "Opens the chest and front body without effort",
                "Counteracts the rounded posture from sitting and breastfeeding",
                "Profoundly relaxing for the respiratory system and heart"
            ],
            contraindications: [
                "Avoid if experiencing heartburn",
                "Pregnancy beyond 20 weeks — use a gentler incline with the support angled"
            ],
            defaultHoldDurationSeconds: 300,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .modified,
                postpartum: .safe,
                notes: "Angle the bolster so the head is higher than the chest; avoid flat backbends in the second and third trimesters."
            ),
            muscleGroups: ["Chest", "Thoracic spine", "Intercostals", "Hip flexors"]
        ),

        // 42. Supported Child's Pose
        YogaPose(
            id: "supported-childs-pose",
            name: "Supported Child's Pose",
            sanskritName: "Salamba Balasana",
            instructions: [
                "Place a bolster lengthwise on the mat; kneel with knees on either side of the bolster.",
                "Fold the torso forward to rest completely on the bolster.",
                "Turn the head to one side and rest on the cheek; switch halfway through.",
                "Let the whole body surrender to the support.",
                "Hold 3–10 minutes."
            ],
            benefits: [
                "Provides full spinal and hip release with zero effort",
                "Deeply nurturing for fatigue, overwhelm, and anxiety",
                "Ideal for menstrual and prenatal practice"
            ],
            contraindications: [
                "Knee discomfort — place a rolled blanket behind the knees"
            ],
            defaultHoldDurationSeconds: 300,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Lower back", "Hips", "Inner groins", "Upper back"]
        ),

        // 43. Side-Lying Savasana
        YogaPose(
            id: "side-lying-savasana",
            name: "Side-Lying Savasana",
            sanskritName: "Parsva Savasana",
            instructions: [
                "Lie on your left side with a pillow or bolster between the knees.",
                "Place a pillow under the head for neck support.",
                "Rest the top arm on the body or on a pillow in front of you.",
                "Close the eyes and breathe naturally, releasing all muscular effort.",
                "Rest for 5–20 minutes."
            ],
            benefits: [
                "Provides safe, complete relaxation from the second trimester of pregnancy onward",
                "Reduces pressure on the vena cava when lying on the left side",
                "Deeply restorative for fatigue and postpartum recovery"
            ],
            contraindications: [
                "None when properly supported"
            ],
            defaultHoldDurationSeconds: 300,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Full body relaxation"]
        ),

        // 44. Supported Bridge Pose
        YogaPose(
            id: "supported-bridge-pose",
            name: "Supported Bridge Pose",
            sanskritName: "Salamba Setu Bandha",
            instructions: [
                "Set a yoga block on its lowest or medium height behind you.",
                "Lie on your back, bend the knees, and lift the hips to slide the block under the sacrum.",
                "Rest the sacrum on the block; extend legs straight or keep knees bent.",
                "Rest arms alongside the body, palms up, and close the eyes.",
                "Hold 3–10 minutes."
            ],
            benefits: [
                "Passively opens the hip flexors and chest with full support",
                "Restores the lumbar curve and relieves lower back fatigue",
                "Calming inversion effect without any effort"
            ],
            contraindications: [
                "Pregnancy beyond 20 weeks — keep the incline very slight and time-limit to 60 seconds"
            ],
            defaultHoldDurationSeconds: 180,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "Use only the lowest block height in the second trimester and limit to 60 seconds per interval; avoid in the third trimester."
            ),
            muscleGroups: ["Hip flexors", "Lower back", "Chest"]
        ),

        // 45. Supported Butterfly / Reclined Bound Angle with Bolster
        YogaPose(
            id: "supported-butterfly",
            name: "Supported Butterfly",
            sanskritName: "Salamba Baddha Konasana",
            instructions: [
                "Sit in front of a bolster placed lengthwise behind you.",
                "Bring the soles of the feet together and let the knees fall open wide.",
                "Lower the torso back onto the bolster; support each knee with a block.",
                "Rest arms alongside the body, palms up; close the eyes.",
                "Hold 5–15 minutes."
            ],
            benefits: [
                "Passively releases inner thighs, groins, and hip flexors",
                "Chest opening counters rounded-shoulder posture",
                "Restorative for menstrual discomfort and third-trimester fatigue"
            ],
            contraindications: [
                "Inner groin pain — reduce the width of the knees"
            ],
            defaultHoldDurationSeconds: 600,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .safe,
                postpartum: .safe,
                notes: "Prop the bolster at an incline so the head is higher than the heart; ideal for all trimesters."
            ),
            muscleGroups: ["Inner thighs", "Groins", "Hip flexors", "Chest"]
        ),

        // 46. Legs Up the Wall — Restorative Variation
        YogaPose(
            id: "legs-up-wall-restorative",
            name: "Legs Up the Wall (Restorative)",
            sanskritName: "Viparita Karani (supported)",
            instructions: [
                "Place a folded blanket or bolster a few inches from the wall.",
                "Sit sideways beside the support, then swing the legs up as you lower onto the prop.",
                "The sacrum rests on the prop and the legs extend up the wall; hips are above the heart.",
                "Rest arms out to the sides, palms up, and breathe softly.",
                "Hold 5–15 minutes."
            ],
            benefits: [
                "Drains oedema from the feet and ankles effectively",
                "Mild inversion that calms the adrenals and lowers blood pressure",
                "Deeply restoring after a long day on the feet"
            ],
            contraindications: [
                "Pregnancy beyond 20 weeks — use a gentle incline only"
            ],
            defaultHoldDurationSeconds: 600,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .modified,
                trimester3: .avoid,
                postpartum: .safe,
                notes: "After week 20 keep the hips at or below the heart level; substitute with Side-Lying Savasana."
            ),
            muscleGroups: ["Hamstrings", "Lower back", "Ankles"]
        )
    ]

    // MARK: - Prenatal-Specific Poses (6)

    private static let prenatal: [YogaPose] = [

        // 47. Pelvic Tilts
        YogaPose(
            id: "pelvic-tilts",
            name: "Pelvic Tilts",
            sanskritName: nil,
            instructions: [
                "Come to hands and knees in Tabletop, or stand with back against a wall.",
                "Exhale and gently draw the lower belly in and up, tilting the pelvis so the lower back flattens.",
                "Inhale to release back to neutral.",
                "Move slowly, focusing on the connection between breath and pelvic movement.",
                "Perform 10–20 repetitions."
            ],
            benefits: [
                "Strengthens the deep core and pelvic floor muscles",
                "Relieves low back ache throughout pregnancy",
                "Prepares the pelvis for labour with optimal positioning"
            ],
            contraindications: [
                "Symphysis pubis dysfunction — avoid in the forward-flexed position"
            ],
            defaultHoldDurationSeconds: 30,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Deep core", "Pelvic floor", "Lower back", "Transverse abdominis"]
        ),

        // 48. Hip Circles (All-Fours)
        YogaPose(
            id: "hip-circles",
            name: "Hip Circles",
            sanskritName: nil,
            instructions: [
                "Begin on hands and knees in Tabletop.",
                "Begin to slowly circle the hips in a wide, smooth motion — right, back, left, forward.",
                "Make the circles as large as is comfortable.",
                "Complete 5–10 circles clockwise, then switch to counter-clockwise.",
                "Breathe freely throughout."
            ],
            benefits: [
                "Mobilises the lumbar spine and sacroiliac joints",
                "Encourages optimal fetal positioning",
                "Relieves pelvic girdle pain and lower back tension during labour"
            ],
            contraindications: [
                "Symphysis pubis dysfunction — keep the movement small and pain-free"
            ],
            defaultHoldDurationSeconds: 60,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Lumbar spine", "Sacroiliac joints", "Hip rotators", "Core"]
        ),

        // 49. Modified Pigeon (Prenatal)
        YogaPose(
            id: "modified-pigeon-prenatal",
            name: "Modified Pigeon (Prenatal)",
            sanskritName: "Kapotasana (modified)",
            instructions: [
                "Sit on a chair or on the floor with a bolster nearby.",
                "Cross the right ankle over the left knee and flex the right foot.",
                "If seated on the floor, the left leg extends behind with support under the left hip.",
                "Fold gently forward until a comfortable stretch appears in the outer right hip.",
                "Hold 1 minute each side."
            ],
            benefits: [
                "Safely opens the outer hip without any abdominal compression",
                "Relieves sciatic discomfort common in pregnancy",
                "Reduces pelvic girdle tension"
            ],
            contraindications: [
                "Symphysis pubis dysfunction — reduce range of motion and keep knees together"
            ],
            defaultHoldDurationSeconds: 60,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Piriformis", "Outer hip", "Glutes", "Hip rotators"]
        ),

        // 50. Squat with Support (Malasana)
        YogaPose(
            id: "squat-with-support",
            name: "Squat with Support",
            sanskritName: "Malasana (supported)",
            instructions: [
                "Stand facing a wall or chair with feet wider than hip-width, toes turned out.",
                "Hold the wall or chair back for support and slowly lower into a deep squat.",
                "Bring the elbows to the inner knees; gently press knees out with elbows while keeping the torso upright.",
                "Place a yoga block or folded blanket under the sit bones for sustained holds.",
                "Hold 30–60 seconds and rise slowly."
            ],
            benefits: [
                "Opens the hips, inner thighs, and pelvic floor",
                "Encourages optimal fetal positioning for birth",
                "Strengthens legs and improves circulation to the pelvis"
            ],
            contraindications: [
                "Avoid if baby is in breech position (may encourage engagement)",
                "Symphysis pubis dysfunction — keep knees closer together"
            ],
            defaultHoldDurationSeconds: 45,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .safe,
                postpartum: .safe,
                notes: "Use support throughout; avoid in late third trimester if pelvic pressure is uncomfortable."
            ),
            muscleGroups: ["Inner thighs", "Hip flexors", "Pelvic floor", "Quadriceps", "Ankles"]
        ),

        // 51. Side-Lying Position
        YogaPose(
            id: "side-lying-position",
            name: "Side-Lying Position",
            sanskritName: nil,
            instructions: [
                "Lie on your left side with a pillow between the knees and another supporting the head.",
                "Optionally, place a long pillow or bolster along the belly for added support.",
                "The bottom arm can extend forward or be under the head.",
                "Breathe deeply into the side ribs and belly.",
                "Rest as long as needed."
            ],
            benefits: [
                "Optimal resting position for circulation in pregnancy",
                "Reduces pressure on the vena cava and aorta",
                "Relieves hip and lower back ache"
            ],
            contraindications: [
                "None — recommended throughout the second and third trimesters"
            ],
            defaultHoldDurationSeconds: 300,
            difficulty: .beginner,
            safetyMatrix: .allSafe,
            muscleGroups: ["Full body rest"]
        ),

        // 52. Cat-Cow for Labour
        YogaPose(
            id: "cat-cow-labour",
            name: "Cat-Cow for Labour",
            sanskritName: "Marjaryasana-Bitilasana (labour variation)",
            instructions: [
                "During or between contractions, come to hands and knees on a mat or birth ball.",
                "Rock the pelvis forward and back with each breath, exaggerating the movement compared to a standard Cat-Cow.",
                "During a contraction: rock back and lower the head into Cat shape; vocalise or breathe through the intensity.",
                "Between contractions: rest in Child's Pose or Tabletop.",
                "Continue as long as beneficial throughout the active phase."
            ],
            benefits: [
                "Creates movement to help the baby rotate and descend",
                "Provides counter-pressure relief for back labour",
                "Helps maintain focus and rhythmic breathing through contractions"
            ],
            contraindications: [
                "Wrist fatigue — use a birth ball instead of hands and knees"
            ],
            defaultHoldDurationSeconds: 60,
            difficulty: .beginner,
            safetyMatrix: PregnancySafetyMatrix(
                trimester1: .safe,
                trimester2: .safe,
                trimester3: .safe,
                postpartum: .safe,
                notes: "Particularly beneficial in active labour; pair with a birth ball if available."
            ),
            muscleGroups: ["Spine", "Pelvic floor", "Core", "Back extensors"]
        )
    ]
}
