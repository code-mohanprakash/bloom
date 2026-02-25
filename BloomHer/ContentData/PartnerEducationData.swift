import Foundation

// MARK: - Partner Tip Category

/// Broad thematic categories that classify each partner tip.
enum PartnerTipCategory: String, CaseIterable, Codable {
    case understanding    = "Understanding"
    case supportActions   = "Support Actions"
    case communication    = "Communication"
    case intimacy         = "Intimacy"
    case pregnancySupport = "Pregnancy Support"
    case ttcSupport       = "TTC Support"

    /// Custom asset name representing this category.
    var icon: String {
        switch self {
        case .understanding:    return "book"
        case .supportActions:   return "heart-filled"
        case .communication:    return "face-smiling"
        case .intimacy:         return "heart-filled"
        case .pregnancySupport: return "yoga"
        case .ttcSupport:       return "leaf"
        }
    }
}

// MARK: - Partner Tip

/// A single piece of educational guidance aimed at the user's partner.
struct PartnerTip: Identifiable {
    /// Stable, human-readable unique identifier.
    let id: String
    /// Short headline displayed in list rows.
    let title: String
    /// Full explanatory body text.
    let description: String
    /// SF Symbol name for the accompanying icon.
    let icon: String
    /// The cycle phase this tip is relevant to, or `nil` if universally applicable.
    let phase: CyclePhase?
    /// Thematic category used for filtering.
    let category: PartnerTipCategory
    /// Whether this tip is also relevant during pregnancy.
    let isPregnancyRelevant: Bool
}

// MARK: - Conception Tip

/// A clinically grounded tip specifically focused on conception and TTC.
struct ConceptionTip: Identifiable {
    /// Stable, human-readable unique identifier.
    let id: String
    /// Short headline displayed in list rows.
    let title: String
    /// Full explanatory body text.
    let description: String
    /// SF Symbol name for the accompanying icon.
    let icon: String
    /// Optional citation or medical source reference.
    let source: String?
}

// MARK: - Supportive Action

/// A discrete act of support the partner can log to show care.
struct SupportiveAction: Identifiable {
    /// Stable, human-readable unique identifier.
    let id: String
    /// Short display label shown in the logging UI.
    let title: String
    /// SF Symbol name for the accompanying icon.
    let icon: String
    /// The cycle phase most relevant to this action, or `nil` if always appropriate.
    let phase: CyclePhase?
}

// MARK: - Partner Education Data

/// Static content repository for the partner education and TTC support features.
///
/// All collections are value types stored as constants — no runtime allocations
/// beyond the initial load. Filter helpers are provided as thin wrappers so
/// call sites never need to import collection operators directly.
enum PartnerEducationData {

    // MARK: Partner Tips

    /// The full catalogue of partner tips covering all four cycle phases,
    /// communication, intimacy, pregnancy, and TTC support.
    static let partnerTips: [PartnerTip] = [

        // ── Menstrual Phase — Understanding ────────────────────────────────

        PartnerTip(
            id: "pt_mens_understand_01",
            title: "What Happens During Menstruation",
            description: "During the menstrual phase the uterine lining sheds because the egg from the previous cycle was not fertilised. Oestrogen and progesterone drop to their lowest levels, which is what triggers bleeding. This usually lasts between three and seven days and is a completely normal, healthy process — not an illness.",
            icon: "drop",
            phase: .menstrual,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_mens_understand_02",
            title: "Why Cramps Happen",
            description: "Prostaglandins — hormone-like compounds — cause the uterine muscle to contract so it can expel the lining. Stronger contractions mean more prostaglandins, which is why some people experience severe cramps while others feel very little. Cramps are real physiological pain, not discomfort to push through. Heat, rest, and over-the-counter anti-inflammatories can all help.",
            icon: "pulse",
            phase: .menstrual,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_mens_understand_03",
            title: "Energy Levels Are Genuinely Low",
            description: "Iron is lost through menstrual blood, and the hormonal drop can cause real fatigue that is similar in feel to mild anaemia. Your partner is not being lazy — their body is actively doing significant work. Expecting the same output as usual during this phase is unrealistic and can feel dismissive.",
            icon: "bolt",
            phase: .menstrual,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_mens_understand_04",
            title: "Emotional Sensitivity Is Hormonal",
            description: "The sharp drop in oestrogen just before and during menstruation can lower serotonin levels, affecting mood and emotional regulation. Feelings of sadness, irritability, or being overwhelmed at this time have a clear physiological basis. Validating these feelings rather than questioning them makes a significant difference.",
            icon: "heart-filled",
            phase: .menstrual,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        // ── Menstrual Phase — Support Actions ──────────────────────────────

        PartnerTip(
            id: "pt_mens_support_01",
            title: "Bring a Heating Pad",
            description: "Heat is one of the most effective non-medication remedies for menstrual cramps — it relaxes the uterine muscle and increases blood flow. Keep a heat pad or hot water bottle accessible without being asked. Simply placing it nearby and saying \"in case you need it\" removes the effort of having to ask.",
            icon: "flame",
            phase: .menstrual,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_mens_support_02",
            title: "Make a Warm Drink",
            description: "Chamomile tea, ginger tea, or a warm herbal blend can ease cramping and provide real comfort. Offering to make one — rather than waiting to be asked — is a small act that communicates attentiveness. Avoid asking if they want caffeine; stick to caffeine-free options as caffeine can intensify cramps.",
            icon: "selfcare-relaxation",
            phase: .menstrual,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_mens_support_03",
            title: "Take on Extra Chores Without Being Asked",
            description: "Proactively handling the cooking, dishes, laundry, or grocery run during your partner's period removes a real burden when their energy is lowest. Do not wait to be directed. Simply saying \"I've got dinner tonight\" or \"I'll handle the washing\" is far more supportive than asking what needs doing.",
            icon: "person",
            phase: .menstrual,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_mens_support_04",
            title: "Suggest a Low-Key Evening In",
            description: "A quiet movie night, a favourite TV show, or simply sitting together removes any social obligation during the days your partner may feel their worst. You do not need to plan anything elaborate — the offer of \"let's just stay in tonight\" can be a significant relief.",
            icon: "pause",
            phase: .menstrual,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_mens_support_05",
            title: "Keep Pain Relief Accessible",
            description: "Ensure ibuprofen or naproxen (anti-inflammatories that reduce prostaglandins) are always stocked at home. If your partner's pain is severe, encourage them to speak to a doctor — conditions like endometriosis are often under-diagnosed and undertreated. Your advocacy can prompt them to seek help they may otherwise minimise.",
            icon: "pill",
            phase: .menstrual,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        // ── Follicular Phase — Understanding ───────────────────────────────

        PartnerTip(
            id: "pt_foll_understand_01",
            title: "Rising Energy and a Better Mood",
            description: "As menstruation ends, oestrogen begins to climb steadily. This hormone drives serotonin production and boosts dopamine sensitivity, which is why your partner may seem noticeably more energetic, optimistic, and sociable during the follicular phase. This is one of the most feel-good windows of the cycle.",
            icon: BloomIcons.sparkles,
            phase: .follicular,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_foll_understand_02",
            title: "Creativity and Motivation Peak",
            description: "Rising oestrogen is associated with improved verbal fluency, sharper focus, and heightened creative thinking. Your partner may have more ideas, want to start new projects, or feel a fresh sense of motivation. Supporting — rather than tempering — that energy has a real positive effect on how they feel about the relationship.",
            icon: BloomIcons.sparkles,
            phase: .follicular,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_foll_understand_03",
            title: "Physical Capacity Is High",
            description: "Endurance, strength, and coordination all tend to peak in the follicular phase due to rising oestrogen and low progesterone. Your partner may be more willing to try new physical activities, exercise more intensely, or push themselves further. This is a great time to plan something active together.",
            icon: "figure-stand",
            phase: .follicular,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        // ── Follicular Phase — Support Actions ─────────────────────────────

        PartnerTip(
            id: "pt_foll_support_01",
            title: "Plan an Active Date",
            description: "Hiking, cycling, a dance class, or a new sport your partner has been curious about — the follicular phase is the ideal time to suggest something active and adventurous. Their energy is high and their recovery is faster. Book it rather than just mentioning it to show you are genuinely invested.",
            icon: "figure-stand",
            phase: .follicular,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_foll_support_02",
            title: "Encourage Their New Ideas",
            description: "If your partner brings up a project, plan, or ambition during this phase, take it seriously. Ask questions, offer to help, or simply listen with genuine interest. The follicular phase is when ideas feel most exciting and momentum is easiest to build. Being their first supporter matters.",
            icon: "star-filled",
            phase: .follicular,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_foll_support_03",
            title: "Try Something New Together",
            description: "This phase is receptive to novelty and adventure. Suggest a restaurant you have both been meaning to try, take a spontaneous day trip, or learn something together — a cooking class, a new board game, an online course. Shared new experiences strengthen connection and your partner will feel energised by them now.",
            icon: "map-pin",
            phase: .follicular,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        // ── Ovulation Phase — Understanding ────────────────────────────────

        PartnerTip(
            id: "pt_ovul_understand_01",
            title: "Peak Energy and Confidence",
            description: "Oestrogen and luteinising hormone (LH) surge at ovulation, bringing your partner to their energetic and social peak for the cycle. They may seem particularly outgoing, confident, and at ease in their body. This is not coincidental — it is biology, and it is real.",
            icon: "checkmark",
            phase: .ovulation,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_ovul_understand_02",
            title: "The Fertility Window",
            description: "Ovulation is the release of a mature egg from the ovary, typically around day 14 of a 28-day cycle, though this varies significantly. The egg survives for 12–24 hours, but sperm can survive up to five days — meaning the most fertile window spans roughly five to six days ending on ovulation day. This is the critical window for conception.",
            icon: "calendar-clock",
            phase: .ovulation,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_ovul_understand_03",
            title: "Physical Signs of Ovulation",
            description: "Your partner may notice changes around ovulation: cervical mucus becomes clear, slippery, and stretchy (similar to raw egg white), a mild one-sided pelvic ache called mittelschmerz, a slight rise in basal body temperature, and increased libido. These are normal and healthy ovulatory signs.",
            icon: "pulse",
            phase: .ovulation,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        // ── Ovulation Phase — Support Actions ──────────────────────────────

        PartnerTip(
            id: "pt_ovul_support_01",
            title: "Plan Social Activities Together",
            description: "Ovulation is the phase when your partner is most naturally sociable and outgoing. Dinner with friends, a party, or any shared social event will feel especially enjoyable for them now. Be the one to make the plans rather than leaving it to them — they will appreciate the effort.",
            icon: "person-plus",
            phase: .ovulation,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_ovul_support_02",
            title: "Appreciate Their Confidence",
            description: "Your partner is at a natural peak of self-assurance during ovulation. Genuine compliments — about how they look, how they carry themselves, or something specific you admire about them — land particularly well now. Be specific and sincere rather than generic.",
            icon: BloomIcons.sparkles,
            phase: .ovulation,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_ovul_support_03",
            title: "Prioritise Connection During the Fertile Window",
            description: "If you are trying to conceive, the days around ovulation are the most important for timed intercourse. Rather than making this feel transactional, focus on connection and intimacy. Spontaneous gestures of affection — not just at bedtime — keep the emotional bond strong and the experience meaningful for both of you.",
            icon: "heart-filled",
            phase: .ovulation,
            category: .intimacy,
            isPregnancyRelevant: false
        ),

        // ── Luteal Phase — Understanding ───────────────────────────────────

        PartnerTip(
            id: "pt_lut_understand_01",
            title: "Progesterone Takes Over",
            description: "After ovulation, progesterone rises sharply to prepare the uterine lining for a potential fertilised egg. Progesterone has a sedating effect — it raises body temperature, slows digestion, and reduces the stimulating effects of oestrogen. This is why your partner may seem more tired, slower, and less energetic than they were just days before.",
            icon: "moon-stars",
            phase: .luteal,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_lut_understand_02",
            title: "PMS Symptoms Are Physiological",
            description: "Premenstrual syndrome affects up to 75% of people who menstruate. Symptoms — bloating, breast tenderness, headaches, irritability, low mood, anxiety, and food cravings — are driven by the hormonal fluctuations at the end of the luteal phase. They are not personality traits or overreactions. A small number of people experience PMDD, a more severe form that warrants medical support.",
            icon: BloomIcons.sparkles,
            phase: .luteal,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_lut_understand_03",
            title: "Food Cravings Have a Reason",
            description: "Progesterone and the subsequent drop in serotonin at the end of the luteal phase drive cravings — particularly for carbohydrates and sweets, which temporarily boost serotonin. The craving is a genuine physiological signal, not a lack of willpower. Satisfy it without commentary.",
            icon: "nutrition",
            phase: .luteal,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_lut_understand_04",
            title: "Why Mood Sensitivity Increases",
            description: "As oestrogen falls in the late luteal phase, serotonin and dopamine activity drops with it. This creates a real neurochemical basis for heightened emotional sensitivity, lower frustration tolerance, and a tendency to interpret neutral events more negatively. Understanding this helps you respond with patience rather than confusion or frustration.",
            icon: "book",
            phase: .luteal,
            category: .understanding,
            isPregnancyRelevant: false
        ),

        // ── Luteal Phase — Support Actions ─────────────────────────────────

        PartnerTip(
            id: "pt_lut_support_01",
            title: "Be Patient With Mood Shifts",
            description: "During the luteal phase your partner's emotional responses may feel outsized relative to the situation. Before reacting defensively, pause and remember the hormonal context. Choose patience over escalation. A calm, warm response — even when it feels unnecessary — prevents arguments that have a biological, not a relational, root cause.",
            icon: "heart-filled",
            phase: .luteal,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_lut_support_02",
            title: "Offer Comfort Without Being Asked",
            description: "Bring them the food they are craving, run a warm bath, or suggest something they find soothing — without waiting to be asked. During the luteal phase, having to ask for care can itself feel exhausting. Anticipating needs removes that friction and demonstrates genuine attentiveness.",
            icon: BloomIcons.sparkles,
            phase: .luteal,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_lut_support_03",
            title: "Suggest Gentle Rather Than Intense Activities",
            description: "Your partner's energy and recovery capacity are reduced in the luteal phase. Swap high-intensity plans for a gentle walk, a yoga class, a slow morning, or a quiet evening in. If they have made plans they now feel too tired to keep, support them in cancelling without guilt rather than pushing them to go.",
            icon: "figure-stand",
            phase: .luteal,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_lut_support_04",
            title: "Use Extra Words of Affirmation",
            description: "The luteal phase is when your partner's self-criticism and inner narrative tend to be harshest. Consistent, specific, sincere affirmations — \"you handled that so well today\", \"I really appreciate you\", \"I think you are doing a brilliant job\" — counteract that internal negativity in a measurable way. Do not save kind words for when asked.",
            icon: "note",
            phase: .luteal,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_lut_support_05",
            title: "Reduce Their Cognitive Load",
            description: "Decision-making and executive function can feel more demanding during the luteal phase. Take things off their plate: plan dinner, handle logistics, deal with the admin task you have both been avoiding. Reducing micro-decisions is a meaningful act of support even if it seems invisible.",
            icon: "checklist",
            phase: .luteal,
            category: .supportActions,
            isPregnancyRelevant: false
        ),

        // ── Communication ──────────────────────────────────────────────────

        PartnerTip(
            id: "pt_comm_01",
            title: "Ask \"How Can I Help?\" and Mean It",
            description: "The most effective version of this question is open, unhurried, and followed by silence. Do not offer a menu of options straight away — let your partner answer in their own words. Then do the thing they ask, without modifying it or explaining why your version is better. Being genuinely helpful means following their lead.",
            icon: "info",
            phase: nil,
            category: .communication,
            isPregnancyRelevant: true
        ),

        PartnerTip(
            id: "pt_comm_02",
            title: "Active Listening Without Fixing",
            description: "When your partner shares how they are feeling, the default impulse is often to offer a solution. During hormonal phases in particular, they frequently do not need a fix — they need to feel heard. Make eye contact, put your phone down, reflect back what you hear (\"it sounds like that was really frustrating\"), and resist the urge to jump to advice unless specifically invited to.",
            icon: "person-circle",
            phase: nil,
            category: .communication,
            isPregnancyRelevant: true
        ),

        PartnerTip(
            id: "pt_comm_03",
            title: "Never Say \"You're Just Hormonal\"",
            description: "This phrase dismisses a real experience and implies the feeling is invalid because of its origin. Yes, hormones influence mood — but that does not make the emotion less real or less deserving of acknowledgement. Saying this typically ends the conversation, damages trust, and leaves your partner feeling unseen. Avoid it entirely, even if you believe it is literally true in the moment.",
            icon: "xmark-circle",
            phase: nil,
            category: .communication,
            isPregnancyRelevant: true
        ),

        PartnerTip(
            id: "pt_comm_04",
            title: "Learn Her Cycle Alongside Her",
            description: "Looking at the BloomHer app together — even briefly — gives you shared language and context. When you understand that today is day 22 and the luteal phase often brings fatigue, you can adjust your plans and expectations proactively rather than reacting to symptoms after the fact. Shared knowledge is a form of care.",
            icon: "books",
            phase: nil,
            category: .communication,
            isPregnancyRelevant: true
        ),

        PartnerTip(
            id: "pt_comm_05",
            title: "Check In — Not Just When Something's Wrong",
            description: "A brief, genuine daily check-in — \"how are you actually feeling today?\" — builds a foundation of openness over time. Do not wait for a crisis or visible distress to ask. Regular check-ins normalise honest communication about health and wellbeing and make it easier for your partner to ask for help when they genuinely need it.",
            icon: "note",
            phase: nil,
            category: .communication,
            isPregnancyRelevant: true
        ),

        // ── TTC Support ────────────────────────────────────────────────────

        PartnerTip(
            id: "pt_ttc_01",
            title: "Managing Expectations Together",
            description: "Most healthy couples under 35 take three to six months to conceive; some take up to a year and still fall within the range of normal. Going into the TTC journey with realistic expectations reduces the emotional impact of months that do not result in pregnancy. Agree in advance that each negative result is information, not failure.",
            icon: "clock",
            phase: nil,
            category: .ttcSupport,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_ttc_02",
            title: "Supporting After a Negative Test",
            description: "A negative pregnancy test — especially after a hopeful month — can be genuinely devastating. Do not minimise it with \"we'll try again next month\". Sit with the disappointment first. Acknowledge that it is hard, let your partner feel it, and show up without agenda. Recovery from the emotional low takes longer than a few hours.",
            icon: "heart",
            phase: nil,
            category: .ttcSupport,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_ttc_03",
            title: "Timing Intimacy Without Pressure",
            description: "Timed intercourse can make sex feel clinical or obligatory, which affects enjoyment and connection for both partners. Aim to maintain regular intimacy throughout the cycle — not just during the fertile window — so sex does not become purely functional. Save urgency for the fertile window but keep affection consistent throughout.",
            icon: "calendar",
            phase: nil,
            category: .ttcSupport,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_ttc_04",
            title: "Your Lifestyle Matters Too",
            description: "Male fertility is significantly affected by lifestyle factors: smoking, heavy alcohol consumption, heat exposure (hot tubs, laptops on laps), and obesity all reduce sperm count, motility, and morphology. The TTC journey is a shared one. Your choices have a direct impact on your chances of conception.",
            icon: "yoga",
            phase: nil,
            category: .ttcSupport,
            isPregnancyRelevant: false
        ),

        PartnerTip(
            id: "pt_ttc_05",
            title: "Encourage — Don't Pressurise",
            description: "Asking about test results, speculating about symptoms, or expressing impatience — even with good intentions — adds pressure that can make the process more stressful and less enjoyable. Let your partner lead communication about where they are in their cycle and how they are feeling. Follow their pace, not your own curiosity.",
            icon: "checkmark-circle",
            phase: nil,
            category: .ttcSupport,
            isPregnancyRelevant: false
        ),

        // ── Pregnancy Support ──────────────────────────────────────────────

        PartnerTip(
            id: "pt_preg_01",
            title: "Attend Appointments When You Can",
            description: "Being present at scans, midwife appointments, and consultant visits communicates that the pregnancy is a shared responsibility, not your partner's project. It also keeps you informed and prepared. If you cannot attend in person, ask for a phone link or ensure your partner can record audio of key discussions to share with you.",
            icon: "stethoscope",
            phase: nil,
            category: .pregnancySupport,
            isPregnancyRelevant: true
        ),

        PartnerTip(
            id: "pt_preg_02",
            title: "Help Prepare the Nursery",
            description: "Practical involvement in preparing for the baby — assembling furniture, organising baby items, decorating the nursery — is tangible evidence of your commitment and excitement. It also reduces the physical workload during late pregnancy when your partner's energy and mobility are significantly reduced.",
            icon: "person",
            phase: nil,
            category: .pregnancySupport,
            isPregnancyRelevant: true
        ),

        PartnerTip(
            id: "pt_preg_03",
            title: "Offer Regular Back Massages",
            description: "Back pain is one of the most common complaints during pregnancy, caused by the shifting centre of gravity, ligament softening due to relaxin, and the growing weight of the uterus. A gentle lower back massage — even ten minutes — provides meaningful relief. Make it a regular offer rather than a one-off event.",
            icon: BloomIcons.sparkles,
            phase: nil,
            category: .pregnancySupport,
            isPregnancyRelevant: true
        ),

        PartnerTip(
            id: "pt_preg_04",
            title: "Be Patient With Physical Discomfort",
            description: "Pregnancy brings nausea, heartburn, swelling, breathlessness, insomnia, pelvic pain, and frequent urination — often simultaneously. Your partner is not complaining for effect. When they describe discomfort, believe them and respond accordingly. Adjust shared plans, reduce your partner's obligations, and problem-solve together where you can.",
            icon: "figure-stand",
            phase: nil,
            category: .pregnancySupport,
            isPregnancyRelevant: true
        ),

        PartnerTip(
            id: "pt_preg_05",
            title: "Prepare as a Birth Partner",
            description: "Attend a birth preparation course together, read about the stages of labour, and discuss your partner's birth preferences in advance. Knowing what to expect reduces panic in the moment and makes you a genuinely useful support rather than a bystander. Ask your partner what they want from you during labour — and listen carefully.",
            icon: "yoga",
            phase: nil,
            category: .pregnancySupport,
            isPregnancyRelevant: true
        ),
    ]

    // MARK: Education Card

    /// A general educational card (not phase-specific) for the partner dashboard.
    struct EducationCard: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let body: String
        let category: String
        let phase: CyclePhase?
    }

    /// General education cards shown on the partner dashboard.
    static let generalEducationCards: [EducationCard] = [
        EducationCard(
            icon: "calendar",
            title: "The Four Phases",
            body: "A typical menstrual cycle is 21–35 days. It has four phases: menstrual, follicular, ovulation, and luteal. Each phase brings distinct hormonal and physical changes.",
            category: "Basics",
            phase: nil
        ),
        EducationCard(
            icon: "pulse",
            title: "Hormonal Rhythm",
            body: "Oestrogen and progesterone rise and fall throughout the cycle. These fluctuations influence mood, energy, libido, skin, and appetite — not 'moodiness'.",
            category: "Science",
            phase: nil
        ),
        EducationCard(
            icon: "heart-filled",
            title: "Emotional Support",
            body: "The best support isn't fixing problems — it's listening, validating, and being present. Ask 'What do you need right now?' rather than assuming.",
            category: "Support",
            phase: nil
        ),
        EducationCard(
            icon: "warning",
            title: "When to Seek Help",
            body: "Severe pain, very heavy periods, or cycles shorter than 21 or longer than 35 days warrant a doctor visit. Supporting that conversation is meaningful.",
            category: "Health",
            phase: nil
        ),
    ]

    // MARK: Filter Helpers

    /// Returns all tips relevant to a specific cycle phase, including phase-agnostic tips.
    static func tips(for phase: CyclePhase) -> [PartnerTip] {
        partnerTips.filter { $0.phase == phase || $0.phase == nil }
    }

    /// Returns all tips belonging to a specific category.
    static func tips(for category: PartnerTipCategory) -> [PartnerTip] {
        partnerTips.filter { $0.category == category }
    }

    // MARK: Conception Tips

    /// Clinically grounded advice for couples who are actively trying to conceive.
    static let conceptionTips: [ConceptionTip] = [

        ConceptionTip(
            id: "ct_01",
            title: "Optimal Timing: 1–2 Days Before Ovulation",
            description: "The egg survives for only 12–24 hours after release, but sperm can survive in the reproductive tract for up to five days. Intercourse in the two days immediately before ovulation — and on ovulation day itself — gives sperm the best chance of being present when the egg arrives. Using OPKs or BBT tracking helps pinpoint this window accurately.",
            icon: "calendar-check",
            source: "NICE CKS: Infertility (2023)"
        ),

        ConceptionTip(
            id: "ct_02",
            title: "Frequency: Every 1–2 Days During the Fertile Window",
            description: "Having sex every one to two days during the fertile window (roughly five to six days ending on ovulation day) optimises sperm availability without significantly reducing sperm count in healthy individuals. Daily sex is also acceptable. Abstaining for long periods before the fertile window is not necessary and may be counterproductive.",
            icon: "refresh",
            source: "ASRM Practice Committee (2021)"
        ),

        ConceptionTip(
            id: "ct_03",
            title: "Folic Acid: Start Before You Conceive",
            description: "Folic acid (400 mcg daily) taken for at least one month before conception and throughout the first trimester reduces the risk of neural tube defects — such as spina bifida — by up to 70%. Both partners benefit from a diet rich in folate (leafy greens, legumes, fortified foods), but a supplement ensures the target dose is reliably met.",
            icon: "leaf",
            source: "NHS England — Vitamins and Supplements in Pregnancy (2024)"
        ),

        ConceptionTip(
            id: "ct_04",
            title: "Alcohol: Reduce or Eliminate for Both Partners",
            description: "Alcohol consumption is associated with reduced female fertility through hormonal disruption and reduced implantation rates. In male partners, regular alcohol use reduces testosterone, sperm count, and sperm motility. The safest approach when TTC is for both partners to eliminate alcohol entirely, or reduce to no more than one to two units occasionally.",
            icon: "drop",
            source: "RCOG: Alcohol and Pregnancy (2022)"
        ),

        ConceptionTip(
            id: "ct_05",
            title: "Nutrition Matters More Than You Think",
            description: "A Mediterranean-style diet — rich in vegetables, legumes, wholegrains, oily fish, and olive oil — is associated with improved fertility outcomes in both men and women. Ultra-processed foods, trans fats, and excess red meat have the opposite effect. Small, consistent dietary improvements over several months before conception can meaningfully improve your chances.",
            icon: "nutrition",
            source: "Chavarro et al., Human Reproduction (2018)"
        ),

        ConceptionTip(
            id: "ct_06",
            title: "Exercise: Moderate Is Best",
            description: "Moderate regular exercise supports healthy weight, reduces insulin resistance, and improves ovulatory function. However, very high-intensity or high-volume exercise — particularly in leaner individuals — can suppress ovulation. Aim for 150 minutes of moderate activity per week. If your partner is an endurance athlete, this is worth discussing with a doctor.",
            icon: "figure-stand",
            source: "ASRM Fertility and Sterility (2022)"
        ),

        ConceptionTip(
            id: "ct_07",
            title: "Stress Has a Real Impact on Fertility",
            description: "Chronic stress elevates cortisol, which can suppress GnRH (the hormone that drives the reproductive cycle) and disrupt ovulation. The TTC process itself is a significant source of stress for many couples. Prioritise activities that reduce stress for both of you: regular movement, adequate sleep, limiting fertility-related rumination, and staying emotionally connected as a couple.",
            icon: "book",
            source: "Lynch et al., Human Reproduction (2014)"
        ),

        ConceptionTip(
            id: "ct_08",
            title: "When to Seek Medical Advice",
            description: "Current guidelines recommend seeking medical evaluation after 12 months of regular unprotected sex if your partner is under 35, and after 6 months if they are 35 or older. Seek earlier assessment if there is a known history of irregular cycles, endometriosis, PCOS, previous STIs, or if the male partner has risk factors for subfertility. Early investigation is always appropriate if concerned.",
            icon: "first-aid",
            source: "NICE CG156: Fertility Problems (2023)"
        ),

        ConceptionTip(
            id: "ct_09",
            title: "OPK Interpretation: What You're Looking For",
            description: "Ovulation predictor kits detect the LH surge that precedes egg release by 24–36 hours. A positive result means the test line is as dark as or darker than the control line — not just any visible line. Test once or twice daily from a few days before expected ovulation. The fertile window begins on the first positive result and extends through the following day.",
            icon: "first-aid",
            source: nil
        ),

        ConceptionTip(
            id: "ct_10",
            title: "BBT Tracking: Confirming Ovulation Has Occurred",
            description: "Basal body temperature rises by 0.2–0.5°C after ovulation due to progesterone and remains elevated until menstruation. BBT tracking confirms that ovulation occurred but cannot predict it in advance. Used alongside OPKs over several cycles, BBT data reveals your partner's typical ovulation pattern and helps identify the most consistent fertile window.",
            icon: "thermometer",
            source: nil
        ),

        ConceptionTip(
            id: "ct_11",
            title: "Male Fertility: Sperm Health Is Fifty Percent of the Equation",
            description: "Approximately 40–50% of fertility difficulties involve a male factor. A semen analysis — checking count, motility, and morphology — is a non-invasive first step that is often overlooked. Sperm quality improves with: maintaining a healthy BMI, avoiding heat exposure, quitting smoking, reducing alcohol, and taking adequate zinc, selenium, and vitamin D.",
            icon: "person-circle",
            source: "NICE CG156: Fertility Problems (2023)"
        ),

        ConceptionTip(
            id: "ct_12",
            title: "CoQ10 Supplementation for Both Partners",
            description: "Coenzyme Q10 (CoQ10) is an antioxidant that supports cellular energy production and is concentrated in both eggs and sperm. Research suggests supplementation (typically 200–600 mg daily) may improve egg quality in older women and sperm parameters in men. Discuss dosage and suitability with a healthcare provider before beginning.",
            icon: "pill",
            source: "Florou et al., Journal of Assisted Reproduction and Genetics (2020)"
        ),

        ConceptionTip(
            id: "ct_13",
            title: "Avoid Lubricants That Harm Sperm",
            description: "Most commercially available lubricants — including saliva — are spermicidal or reduce sperm motility at physiological concentrations. If lubricant is needed, use a product specifically formulated to be sperm-safe (often labelled as \"fertility-friendly\"). Hydroxyethylcellulose-based lubricants such as Pre-Seed are clinically validated for TTC use.",
            icon: "drop",
            source: "ASRM Practice Committee (2021)"
        ),

        ConceptionTip(
            id: "ct_14",
            title: "Track More Than One Fertility Sign",
            description: "No single fertility sign gives a complete picture. Combining OPK results, BBT charting, and cervical mucus observation (the TCOYF method or Billings method) provides a much more reliable window onto the cycle than any one measure alone. After two to three cycles of combined tracking, patterns become far easier to read.",
            icon: "chart-line",
            source: nil
        ),

        ConceptionTip(
            id: "ct_15",
            title: "Vitamin D: Often Overlooked in Fertility",
            description: "Vitamin D receptors are present in the ovary, endometrium, and testes. Deficiency is associated with reduced ovarian reserve, impaired implantation, and lower sperm motility. In many regions, particularly outside equatorial latitudes, the majority of people are deficient — especially in winter months. A blood test and daily supplementation of 1000–2000 IU is a sensible low-risk step for both partners.",
            icon: BloomIcons.sparkles,
            source: "Chu et al., Reproductive Biology and Endocrinology (2018)"
        ),
    ]

    // MARK: Supportive Actions

    /// Discrete acts of care the partner can log to build a record of emotional and practical support.
    static let supportiveActions: [SupportiveAction] = [

        SupportiveAction(
            id: "sa_01",
            title: "Made Dinner",
            icon: "nutrition",
            phase: nil
        ),

        SupportiveAction(
            id: "sa_02",
            title: "Did the Dishes",
            icon: BloomIcons.sparkles,
            phase: nil
        ),

        SupportiveAction(
            id: "sa_03",
            title: "Brought Flowers",
            icon: "camera-plus",
            phase: nil
        ),

        SupportiveAction(
            id: "sa_04",
            title: "Gave a Massage",
            icon: BloomIcons.sparkles,
            phase: .luteal
        ),

        SupportiveAction(
            id: "sa_05",
            title: "Ran a Bath",
            icon: "selfcare-relaxation",
            phase: .menstrual
        ),

        SupportiveAction(
            id: "sa_06",
            title: "Watched Their Favourite Show",
            icon: "pause",
            phase: .menstrual
        ),

        SupportiveAction(
            id: "sa_07",
            title: "Went to an Appointment Together",
            icon: "first-aid",
            phase: nil
        ),

        SupportiveAction(
            id: "sa_08",
            title: "Said Something Kind",
            icon: "note",
            phase: nil
        ),

        SupportiveAction(
            id: "sa_09",
            title: "Took Care of the Kids",
            icon: "yoga",
            phase: nil
        ),

        SupportiveAction(
            id: "sa_10",
            title: "Let Them Sleep In",
            icon: "moon-stars",
            phase: .luteal
        ),

        SupportiveAction(
            id: "sa_11",
            title: "Brought a Snack",
            icon: "nutrition",
            phase: .luteal
        ),

        SupportiveAction(
            id: "sa_12",
            title: "Listened Without Fixing",
            icon: "person-circle",
            phase: nil
        ),

        SupportiveAction(
            id: "sa_13",
            title: "Took Over Errands",
            icon: "checklist",
            phase: .menstrual
        ),

        SupportiveAction(
            id: "sa_14",
            title: "Planned a Date",
            icon: "map-pin",
            phase: .follicular
        ),

        SupportiveAction(
            id: "sa_15",
            title: "Sent a Thoughtful Message",
            icon: "note",
            phase: nil
        ),

        SupportiveAction(
            id: "sa_16",
            title: "Made a Warm Drink",
            icon: "selfcare-relaxation",
            phase: .menstrual
        ),

        SupportiveAction(
            id: "sa_17",
            title: "Tidied the House",
            icon: "person",
            phase: nil
        ),

        SupportiveAction(
            id: "sa_18",
            title: "Did the Grocery Shop",
            icon: "checklist",
            phase: nil
        ),

        SupportiveAction(
            id: "sa_19",
            title: "Gave a Genuine Compliment",
            icon: "star-filled",
            phase: .ovulation
        ),

        SupportiveAction(
            id: "sa_20",
            title: "Left Them Space to Rest",
            icon: "moon-stars",
            phase: .luteal
        ),
    ]
}
