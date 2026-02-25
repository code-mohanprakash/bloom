import Foundation

// MARK: - SelfCareData

/// Static content store for all self-care suggestions and breathing patterns
/// in the BloomHer app.
///
/// Items are keyed by cycle phase and life context (pregnancy). Use the helper
/// methods to retrieve contextually relevant content rather than filtering
/// `items` directly.
enum SelfCareData {

    // MARK: - Full Collection

    static let items: [SelfCareItem] = relaxationItems
        + movementItems
        + mindfulnessItems
        + socialItems
        + creativeItems
        + nutritionItems
        + pregnancyItems

    // MARK: - Query Helpers

    /// All items associated with a given cycle phase, including universal items
    /// (where `phase == nil`).
    static func items(for phase: CyclePhase) -> [SelfCareItem] {
        items.filter { $0.phase == phase || $0.phase == nil }
    }

    /// All items belonging to a specific category.
    static func items(for category: SelfCareCategory) -> [SelfCareItem] {
        items.filter { $0.category == category }
    }

    /// All items appropriate during pregnancy.
    static var pregnancySafeItems: [SelfCareItem] {
        items.filter { $0.isPregnancy || $0.phase == nil }
    }

    /// Five deterministic daily suggestions for a given phase and date.
    ///
    /// The selection rotates daily without storing any state, ensuring a
    /// fresh-feeling set of suggestions each morning.
    static func dailySuggestions(for phase: CyclePhase, date: Date) -> [SelfCareItem] {
        let pool = items(for: phase)
        guard !pool.isEmpty else { return [] }
        let daysSinceEpoch = Calendar.current.dateComponents(
            [.day],
            from: Date(timeIntervalSince1970: 0),
            to: date
        ).day ?? 0
        var suggestions: [SelfCareItem] = []
        let count = min(5, pool.count)
        for i in 0..<count {
            let index = (abs(daysSinceEpoch) + i * 7) % pool.count
            suggestions.append(pool[index])
        }
        return suggestions
    }

    // MARK: - Breathing Patterns

    static let breathingPatterns: [BreathingPattern] = [
        .boxBreathing,
        .fourSevenEight,
        .calmBreath,
        energisingBreath,
        laborBreath,
        groundingBreath,
    ]

    /// Energising breath: quick inhale followed by slow exhale to increase alertness.
    static let energisingBreath = BreathingPattern(
        id: "energising",
        name: "Energising Breath",
        description: "Quick inhale followed by a long, controlled exhale to boost alertness and lift energy.",
        inhaleSeconds: 2,
        holdSeconds: 0,
        exhaleSeconds: 4,
        holdAfterExhaleSeconds: 0,
        rounds: 8
    )

    /// Labour breathing: slow, paced breathing designed for managing contraction intensity.
    static let laborBreath = BreathingPattern(
        id: "labor",
        name: "Labour Breathing",
        description: "Slow, rhythmic breathing to stay calm and conserve energy during contractions. Breathe in for 4, out for 6, releasing all tension on the exhale.",
        inhaleSeconds: 4,
        holdSeconds: 0,
        exhaleSeconds: 6,
        holdAfterExhaleSeconds: 2,
        rounds: 10
    )

    /// Grounding breath: slightly longer exhale with a pause to activate the parasympathetic nervous system.
    static let groundingBreath = BreathingPattern(
        id: "grounding",
        name: "Grounding Breath",
        description: "A gentle pause after exhaling activates the parasympathetic system, reducing stress and anchoring attention to the present moment.",
        inhaleSeconds: 5,
        holdSeconds: 2,
        exhaleSeconds: 5,
        holdAfterExhaleSeconds: 3,
        rounds: 5
    )

    // MARK: - Relaxation Items

    private static let relaxationItems: [SelfCareItem] = [
        SelfCareItem(
            id: "rel-001",
            title: "Warm Bath with Epsom Salts",
            description: "Dissolve two cups of Epsom salts in a warm bath and soak for 20 minutes. Magnesium absorbed through the skin relaxes muscles, eases cramps, and calms the nervous system.",
            icon: "drop",
            phase: .menstrual,
            category: .relaxation
        ),
        SelfCareItem(
            id: "rel-002",
            title: "Heating Pad for Cramp Relief",
            description: "Apply a low-heat pad or hot water bottle to your lower abdomen or back for 15–20 minutes. Heat increases blood flow and relieves uterine muscle tension.",
            icon: "thermometer",
            phase: .menstrual,
            category: .relaxation
        ),
        SelfCareItem(
            id: "rel-003",
            title: "Cosy Blanket and a Good Book",
            description: "Wrap yourself in a soft blanket and lose yourself in a favourite book. Permission to be still is one of the greatest gifts you can give yourself during your period.",
            icon: "book",
            phase: .menstrual,
            category: .relaxation
        ),
        SelfCareItem(
            id: "rel-004",
            title: "Lavender Essential Oil Roll-On",
            description: "Apply diluted lavender oil to your temples, wrists, and the nape of your neck. Lavender's linalool content has clinical evidence for reducing anxiety and promoting calm.",
            icon: "leaf",
            phase: .menstrual,
            category: .relaxation
        ),
        SelfCareItem(
            id: "rel-005",
            title: "Warm Herbal Drink",
            description: "Brew chamomile, peppermint, or raspberry leaf tea and sip slowly without a screen in front of you. The ritual itself signals safety to your nervous system.",
            icon: "selfcare-relaxation",
            phase: .menstrual,
            category: .relaxation
        ),
        SelfCareItem(
            id: "rel-006",
            title: "Digital Detox Evening",
            description: "Switch off devices two hours before bed. Blue light suppresses melatonin; a screen-free evening dramatically improves sleep quality during the luteal and menstrual phases.",
            icon: "moon-stars",
            phase: .luteal,
            category: .relaxation
        ),
        SelfCareItem(
            id: "rel-007",
            title: "Candle-Lit Wind-Down",
            description: "Dim the lights, light a candle with a calming scent (lavender, sandalwood, vanilla), and spend 20 minutes doing whatever feels restorative — reading, journaling, or simply sitting.",
            icon: "flame",
            phase: .luteal,
            category: .relaxation
        ),
        SelfCareItem(
            id: "rel-008",
            title: "Progressive Muscle Relaxation",
            description: "Tense each muscle group for five seconds, then release for 30 seconds, working from feet to face. This technique reliably reduces physical tension and anxiety within 20 minutes.",
            icon: "yoga",
            category: .relaxation
        ),
        SelfCareItem(
            id: "rel-009",
            title: "10-Minute Nap",
            description: "A brief 10-minute nap improves alertness, mood, and cognitive performance for up to two hours. Set an alarm and keep it short to avoid the grogginess of deeper sleep stages.",
            icon: "moon-stars",
            phase: .menstrual,
            category: .relaxation
        ),
        SelfCareItem(
            id: "rel-010",
            title: "Early Bedtime Tonight",
            description: "Choose sleep over the late scroll. Going to bed an hour earlier during the luteal and menstrual phases supports cortisol regulation and reduces the severity of PMS symptoms.",
            icon: "moon-stars",
            phase: .luteal,
            category: .relaxation
        ),
        SelfCareItem(
            id: "rel-011",
            title: "Gentle Music and Rest",
            description: "Put on ambient, classical, or nature soundscapes and lie down without an agenda. Passive music listening at 60–80bpm shifts the autonomic nervous system toward rest.",
            icon: "selfcare-relaxation",
            category: .relaxation
        ),
        SelfCareItem(
            id: "rel-012",
            title: "Foot Soak with Peppermint",
            description: "Soak tired feet in warm water with a few drops of peppermint oil for 15 minutes. Peppermint's menthol content cools inflammation while the warmth improves circulation.",
            icon: "drop",
            category: .relaxation
        ),
    ]

    // MARK: - Movement Items

    private static let movementItems: [SelfCareItem] = [
        SelfCareItem(
            id: "mov-001",
            title: "Gentle Yin Yoga",
            description: "Hold passive, floor-based stretches for 3–5 minutes each. Yin yoga targets connective tissue and the parasympathetic nervous system, making it ideal during menstruation.",
            icon: "yoga",
            phase: .menstrual,
            category: .movement
        ),
        SelfCareItem(
            id: "mov-002",
            title: "20-Minute Walk in Nature",
            description: "A gentle outdoor walk lowers cortisol, boosts serotonin, and provides gentle movement without over-taxing the body during menstruation. Even 10 minutes makes a difference.",
            icon: "figure-stand",
            phase: .menstrual,
            category: .movement
        ),
        SelfCareItem(
            id: "mov-003",
            title: "Morning Stretch Sequence",
            description: "Spend 10 minutes on a gentle full-body stretch before getting out of bed. Include hip circles, cat-cow, and child's pose to release tension accumulated overnight.",
            icon: "yoga",
            category: .movement
        ),
        SelfCareItem(
            id: "mov-004",
            title: "Dance to Your Favourite Song",
            description: "Put on a song you love and move freely for three to five minutes. Spontaneous movement releases endorphins, reduces stress hormones, and is one of the fastest mood lifters available.",
            icon: "selfcare-relaxation",
            phase: .follicular,
            category: .movement
        ),
        SelfCareItem(
            id: "mov-005",
            title: "Pilates Core Session",
            description: "A 20–30 minute pilates session during the follicular or ovulatory phase channels rising energy into strength and stability. Focus on breath-connected movement.",
            icon: "yoga",
            phase: .follicular,
            category: .movement
        ),
        SelfCareItem(
            id: "mov-006",
            title: "Swim or Aqua Walk",
            description: "Water supports the body's weight, making swimming ideal during menstruation and late pregnancy. The resistance of water also delivers a gentle cardiovascular workout.",
            icon: "figure-stand",
            category: .movement
        ),
        SelfCareItem(
            id: "mov-007",
            title: "Power Walk with Podcast",
            description: "Pair a brisk 30-minute walk with an inspiring podcast. Combining physical movement with mental stimulation suits the energetic follicular phase perfectly.",
            icon: "figure-stand",
            phase: .follicular,
            category: .movement
        ),
        SelfCareItem(
            id: "mov-008",
            title: "Restorative Yoga",
            description: "Use bolsters, blankets, and blocks to support long-held poses. Restorative yoga activates the rest-and-digest system and is especially beneficial during the luteal phase.",
            icon: "yoga",
            phase: .luteal,
            category: .movement
        ),
        SelfCareItem(
            id: "mov-009",
            title: "Cycle Synced Strength Training",
            description: "Lift heavier or push harder during the follicular and ovulatory phases when oestrogen and testosterone peak. Dial back intensity during the luteal and menstrual phases.",
            icon: "figure-stand",
            phase: .ovulation,
            category: .movement
        ),
        SelfCareItem(
            id: "mov-010",
            title: "Hip-Opening Yoga Flow",
            description: "Hip flexors and the sacrum hold much of the tension experienced during menstruation. A 20-minute hip-opening sequence provides significant relief for cramping and lower back pain.",
            icon: "yoga",
            phase: .menstrual,
            category: .movement
        ),
        SelfCareItem(
            id: "mov-011",
            title: "Gentle Evening Stretch",
            description: "Five minutes of light stretching before bed — particularly hamstrings, hips, and shoulders — improves sleep onset and reduces the overnight muscle tension common in the luteal phase.",
            icon: "yoga",
            phase: .luteal,
            category: .movement
        ),
        SelfCareItem(
            id: "mov-012",
            title: "Outdoor Cycling",
            description: "Cycling outdoors combines cardiovascular fitness, vitamin D from sunlight, and the mental health benefits of fresh air. Ideal during the follicular and ovulatory phases.",
            icon: "figure-stand",
            phase: .ovulation,
            category: .movement
        ),
    ]

    // MARK: - Mindfulness Items

    private static let mindfulnessItems: [SelfCareItem] = [
        SelfCareItem(
            id: "min-001",
            title: "5-Minute Seated Meditation",
            description: "Sit comfortably, close your eyes, and focus only on the sensation of your breath for five minutes. When thoughts arise, gently return attention to your breathing without judgment.",
            icon: "book",
            category: .mindfulness
        ),
        SelfCareItem(
            id: "min-002",
            title: "10-Minute Body Scan",
            description: "Lie on your back and systematically direct attention through each part of your body from feet to crown. Notice sensation without trying to change it. Deeply calming for the menstrual phase.",
            icon: "yoga",
            phase: .menstrual,
            category: .mindfulness
        ),
        SelfCareItem(
            id: "min-003",
            title: "Mindful Eating Practice",
            description: "Eat one meal today without distractions — no phone, no screen. Chew slowly, noticing flavours and textures. This practice improves digestion and deepens appreciation for nourishment.",
            icon: "nutrition",
            category: .mindfulness
        ),
        SelfCareItem(
            id: "min-004",
            title: "Gratitude Practice",
            description: "Write down three things you are genuinely grateful for today. Gratitude practice rewires neural pathways toward positive emotion and is most impactful when practised consistently.",
            icon: "heart-filled",
            category: .mindfulness
        ),
        SelfCareItem(
            id: "min-005",
            title: "Five Senses Grounding",
            description: "Name five things you can see, four you can feel, three you can hear, two you can smell, and one you can taste. This technique interrupts anxiety and grounds you in the present moment instantly.",
            icon: "person-circle",
            category: .mindfulness
        ),
        SelfCareItem(
            id: "min-006",
            title: "15-Minute Guided Meditation",
            description: "Use a guided meditation app or recording for a deeper mindfulness session. Focus on phase-specific themes: compassion during menstruation, intention-setting during the follicular phase.",
            icon: "pause",
            category: .mindfulness
        ),
        SelfCareItem(
            id: "min-007",
            title: "Mindful Morning Ritual",
            description: "Before reaching for your phone, spend five minutes in quiet awareness — noting how you feel physically and emotionally. Setting intention at the start of the day shapes the rest of it.",
            icon: BloomIcons.sparkles,
            category: .mindfulness
        ),
        SelfCareItem(
            id: "min-008",
            title: "Loving-Kindness Meditation",
            description: "Silently repeat phrases — 'May I be well, may I be happy, may I be at peace' — first for yourself, then expanding to loved ones and beyond. Particularly powerful during emotional luteal days.",
            icon: "heart",
            phase: .luteal,
            category: .mindfulness
        ),
        SelfCareItem(
            id: "min-009",
            title: "Mindful Nature Observation",
            description: "Spend 10 minutes sitting outdoors and simply observing — clouds, birds, leaves, wind. This passive attention practice restores directed attention and reduces mental fatigue.",
            icon: "leaf",
            phase: .follicular,
            category: .mindfulness
        ),
        SelfCareItem(
            id: "min-010",
            title: "Cycle Journaling Check-In",
            description: "Take five minutes to write about where you are in your cycle, how your body feels today, and one thing you want to offer yourself. Tracking patterns over time builds deep cycle literacy.",
            icon: "edit",
            category: .mindfulness
        ),
        SelfCareItem(
            id: "min-011",
            title: "Box Breathing Session",
            description: "Practise four rounds of box breathing (inhale 4 — hold 4 — exhale 4 — hold 4). This simple technique activates the parasympathetic nervous system within minutes.",
            icon: "checkmark",
            category: .mindfulness
        ),
        SelfCareItem(
            id: "min-012",
            title: "Evening Reflection",
            description: "Before sleep, spend three minutes reflecting on one thing that went well today and one thing you are looking forward to tomorrow. This shifts cognitive focus away from ruminative worry.",
            icon: "moon-stars",
            category: .mindfulness
        ),
    ]

    // MARK: - Social Items

    private static let socialItems: [SelfCareItem] = [
        SelfCareItem(
            id: "soc-001",
            title: "Call a Friend",
            description: "Reach out to someone who lifts your energy. A genuine conversation — even ten minutes — raises oxytocin, lowers cortisol, and reminds you that you are deeply connected.",
            icon: "person-circle",
            category: .social
        ),
        SelfCareItem(
            id: "soc-002",
            title: "Write a Handwritten Letter",
            description: "Sit with a pen and paper and write to someone you love, appreciate, or have been thinking about. The act of writing slowly and intentionally is therapeutic for both sender and recipient.",
            icon: "note",
            phase: .luteal,
            category: .social
        ),
        SelfCareItem(
            id: "soc-003",
            title: "Plan a Friend Date",
            description: "Use the social energy of the ovulatory phase to plan something meaningful — a dinner, a walk, an activity. You are naturally most communicative and charming now; enjoy it.",
            icon: "calendar",
            phase: .ovulation,
            category: .social
        ),
        SelfCareItem(
            id: "soc-004",
            title: "Join a Community Class",
            description: "Yoga, dance, painting, cooking — group classes combine learning with connection. The follicular phase is ideal for trying something new with others.",
            icon: "person-plus",
            phase: .follicular,
            category: .social
        ),
        SelfCareItem(
            id: "soc-005",
            title: "Volunteer for an Hour",
            description: "Contributing to your community activates the 'helper's high' — a real neurobiological phenomenon. Even small acts of service shift focus outward and elevate mood.",
            icon: "heart-filled",
            phase: .ovulation,
            category: .social
        ),
        SelfCareItem(
            id: "soc-006",
            title: "Share How You Are Really Feeling",
            description: "Choose one trusted person and let them know genuinely how you are. Vulnerability in safe relationships deepens bonds and releases the physiological burden of carrying emotions alone.",
            icon: "note",
            phase: .luteal,
            category: .social
        ),
        SelfCareItem(
            id: "soc-007",
            title: "Cook and Share a Meal",
            description: "Invite someone to share a meal you have cooked. The act of nourishing another person is deeply grounding and transforms eating from a solo necessity into a social ritual.",
            icon: "nutrition",
            phase: .follicular,
            category: .social
        ),
        SelfCareItem(
            id: "soc-008",
            title: "Screen-Free Family Time",
            description: "Dedicate one hour to being fully present with the people in your home — no phones, no background TV. Quality presence is the most valuable gift you can offer those you love.",
            icon: "person-plus",
            category: .social
        ),
    ]

    // MARK: - Creative Items

    private static let creativeItems: [SelfCareItem] = [
        SelfCareItem(
            id: "cre-001",
            title: "Stream of Consciousness Journaling",
            description: "Set a timer for 10 minutes and write without stopping or editing. Let whatever is in your mind spill onto the page. This technique clears mental clutter and surfaces unexpected insights.",
            icon: "edit",
            phase: .menstrual,
            category: .creative
        ),
        SelfCareItem(
            id: "cre-002",
            title: "Intuitive Drawing or Doodling",
            description: "Pick up a pen or coloured pencils and draw freely without a goal. Right-brain creative expression bypasses the inner critic and can process emotions that words struggle to reach.",
            icon: "selfcare-creative",
            category: .creative
        ),
        SelfCareItem(
            id: "cre-003",
            title: "Try a New Recipe",
            description: "Cooking a new recipe is a meditative, creative act. The sensory engagement — chopping, smelling, tasting — keeps attention fully in the present moment.",
            icon: "nutrition",
            phase: .follicular,
            category: .creative
        ),
        SelfCareItem(
            id: "cre-004",
            title: "Tend Your Plants or Garden",
            description: "Hands in soil increases serotonin production through contact with Mycobacterium vaccae. Even watering a windowsill herb garden counts. Growth is a powerful metaphor for the follicular phase.",
            icon: "leaf",
            phase: .follicular,
            category: .creative
        ),
        SelfCareItem(
            id: "cre-005",
            title: "Create a Mood Board",
            description: "Collect images, colours, and words that represent your vision for this cycle, season, or year. Externalising an inner vision makes it more concrete and motivating.",
            icon: "camera-plus",
            phase: .follicular,
            category: .creative
        ),
        SelfCareItem(
            id: "cre-006",
            title: "Play an Instrument",
            description: "Even 15 minutes of playing — or learning — an instrument reduces cortisol, improves fine motor coordination, and activates parts of the brain that everyday tasks leave dormant.",
            icon: "selfcare-relaxation",
            category: .creative
        ),
        SelfCareItem(
            id: "cre-007",
            title: "Write a Poem or Song",
            description: "You do not need to be a poet. Distil one emotion or observation into a few lines. Poetic compression forces you to find the essence of an experience — clarifying and cathartic.",
            icon: "note",
            phase: .menstrual,
            category: .creative
        ),
        SelfCareItem(
            id: "cre-008",
            title: "Rearrange a Space",
            description: "Rearranging a shelf, desk, or corner of your home exercises spatial creativity and gives you a tangible sense of control and renewal. Perfect for channelling ovulatory energy.",
            icon: "checklist",
            phase: .ovulation,
            category: .creative
        ),
        SelfCareItem(
            id: "cre-009",
            title: "Photography Walk",
            description: "Take your phone or camera for a walk and photograph only what genuinely catches your eye. This trains observational awareness and reconnects you with beauty in the everyday.",
            icon: "camera-plus",
            phase: .ovulation,
            category: .creative
        ),
        SelfCareItem(
            id: "cre-010",
            title: "Cycle Letter to Yourself",
            description: "Write a brief letter to yourself to be read at the same phase next cycle. Note what you learned, what you struggled with, and what you wish for future you. A powerful cycle-to-cycle practice.",
            icon: "note",
            phase: .luteal,
            category: .creative
        ),
    ]

    // MARK: - Nutrition / Nourishment Items

    private static let nutritionItems: [SelfCareItem] = [
        SelfCareItem(
            id: "nut-001",
            title: "Prepare an Iron-Rich Meal",
            description: "Cook spinach and lentil dhal, a lean beef stir-fry, or a chickpea curry. Replenishing iron during your period directly reduces fatigue, brain fog, and weakness.",
            icon: "nutrition",
            phase: .menstrual,
            category: .nutrition
        ),
        SelfCareItem(
            id: "nut-002",
            title: "Make a Nourishing Bone Broth",
            description: "Slow-simmer bones with vegetables and apple cider vinegar for four or more hours to extract collagen, minerals, and amino acids. Sip as a warm, restorative drink during menstruation.",
            icon: "selfcare-relaxation",
            phase: .menstrual,
            category: .nutrition
        ),
        SelfCareItem(
            id: "nut-003",
            title: "Batch-Cook for the Week",
            description: "Spend an hour on Sunday preparing grains, roasted vegetables, and a protein source. Having nourishing food ready reduces the likelihood of reaching for processed foods when energy dips.",
            icon: "checklist",
            category: .nutrition
        ),
        SelfCareItem(
            id: "nut-004",
            title: "Enjoy Dark Chocolate Mindfully",
            description: "A square or two of 70%+ dark chocolate provides magnesium and antioxidants. Eating it slowly and mindfully transforms a craving into a genuine self-care ritual.",
            icon: "heart-filled",
            phase: .luteal,
            category: .nutrition
        ),
        SelfCareItem(
            id: "nut-005",
            title: "Hydration Tracking",
            description: "Fill a 1.5-litre water bottle first thing in the morning with the goal of finishing it before dinner. Adequate hydration is one of the highest-leverage, lowest-effort health habits.",
            icon: "drop",
            category: .nutrition
        ),
        SelfCareItem(
            id: "nut-006",
            title: "Fermented Food Ritual",
            description: "Add a tablespoon of sauerkraut or kimchi to your lunch, or stir a tablespoon of natural yogurt into a sauce. Small consistent doses of probiotics support the gut-hormone axis meaningfully.",
            icon: "leaf",
            phase: .follicular,
            category: .nutrition
        ),
        SelfCareItem(
            id: "nut-007",
            title: "Smoothie with Phase-Specific Ingredients",
            description: "Blend a smoothie tailored to your phase: spinach and berries (menstrual), sprouted flax and banana (follicular), mango and chia (ovulatory), or oat milk and dates (luteal).",
            icon: "drop",
            category: .nutrition
        ),
        SelfCareItem(
            id: "nut-008",
            title: "Eat at Regular Intervals",
            description: "Blood sugar stability is a cornerstone of hormonal health. Aim to eat every 3–4 hours, starting within an hour of waking, to prevent cortisol spikes from skipped meals.",
            icon: "clock",
            category: .nutrition
        ),
    ]

    // MARK: - Pregnancy-Specific Items

    private static let pregnancyItems: [SelfCareItem] = [
        SelfCareItem(
            id: "prg-sc-001",
            title: "Prenatal Yoga",
            description: "A 20–30 minute prenatal yoga session maintains flexibility, reduces lower back pain, and prepares the body for labour through hip-opening and breathing practice. Always use a qualified prenatal class.",
            icon: "yoga",
            isPregnancy: true,
            category: .movement
        ),
        SelfCareItem(
            id: "prg-sc-002",
            title: "Bump Massage with Oil",
            description: "Massage your abdomen in slow, circular motions using a pregnancy-safe oil (coconut, almond, or dedicated bump oil). This ritual connects you with your body and your baby while hydrating skin.",
            icon: "heart-filled",
            isPregnancy: true,
            category: .relaxation
        ),
        SelfCareItem(
            id: "prg-sc-003",
            title: "Write in a Pregnancy Journal",
            description: "Record your symptoms, feelings, and milestones. Pregnancy journaling helps process the emotional complexity of pregnancy and becomes a cherished record for the future.",
            icon: "edit",
            isPregnancy: true,
            category: .creative
        ),
        SelfCareItem(
            id: "prg-sc-004",
            title: "Pregnancy Meditation",
            description: "Use a guided pregnancy meditation to connect with your baby, release fear around birth, and cultivate calm. Even 10 minutes per day measurably reduces prenatal anxiety.",
            icon: "book",
            isPregnancy: true,
            category: .mindfulness
        ),
        SelfCareItem(
            id: "prg-sc-005",
            title: "Pelvic Floor Exercises",
            description: "Perform 10–15 Kegel contractions three times daily. A strong pelvic floor supports the weight of the growing uterus, aids labour, and significantly speeds postpartum recovery.",
            icon: "yoga",
            isPregnancy: true,
            category: .movement
        ),
        SelfCareItem(
            id: "prg-sc-006",
            title: "Warm (Not Hot) Bath",
            description: "Soak in a comfortably warm — not hot — bath for up to 20 minutes. Avoid water above 37.8°C during pregnancy. Add plain Epsom salts and lavender for extra relaxation.",
            icon: "drop",
            isPregnancy: true,
            category: .relaxation
        ),
        SelfCareItem(
            id: "prg-sc-007",
            title: "Hypnobirthing Practice",
            description: "Practice your hypnobirthing scripts, visualisations, or affirmations. Regular practice makes these tools automatic during labour, reducing fear-tension-pain responses.",
            icon: "pulse",
            isPregnancy: true,
            category: .mindfulness
        ),
        SelfCareItem(
            id: "prg-sc-008",
            title: "Connect with Your Birth Community",
            description: "Join an NCT class, pregnancy yoga group, or online forum. Shared experience with other pregnant women normalises fears, builds support networks, and reduces isolation.",
            icon: "person-plus",
            isPregnancy: true,
            category: .social
        ),
        SelfCareItem(
            id: "prg-sc-009",
            title: "Rest with Legs Elevated",
            description: "Lie on your left side with your legs slightly elevated on a pillow for 20–30 minutes. This position improves blood return from the legs, reduces oedema, and optimises blood flow to the placenta.",
            icon: "moon-stars",
            isPregnancy: true,
            category: .relaxation
        ),
        SelfCareItem(
            id: "prg-sc-010",
            title: "Slow Antenatal Walk",
            description: "A 20–30 minute walk at a comfortable pace maintains cardiovascular fitness, lifts mood through endorphin release, and encourages the baby into an optimal position for labour.",
            icon: "figure-stand",
            isPregnancy: true,
            category: .movement
        ),
    ]
}
