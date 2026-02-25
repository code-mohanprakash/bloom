//
//  ChecklistData.swift
//  BloomHer
//
//  Pregnancy checklist items covering the full 40-week journey.
//
//  Design notes:
//    - Items are keyed by `week`, the earliest gestational week at which the
//      task becomes actionable. The query helpers allow views to show all
//      cumulative items (items(for:)) or only newly-relevant items (newItems(for:)).
//    - Category hex colors are sourced from BloomColors:
//        Medical      → primaryRose     #F4A0B5
//        Preparation  → accentLavender  #C7B8EA
//        Shopping     → accentPeach     #F9D5A7
//        Self-Care    → sageGreen       #A8D5BA
//        Administrative → luteal blue   #B8C9E8
//    - SF Symbols icon names are validated against the iOS 17+ symbol library.
//
//  All content is informational only and does not constitute medical advice.
//

import Foundation
import SwiftUI

// MARK: - ChecklistCategory

/// The category a checklist item belongs to, driving icon and color theming.
enum ChecklistCategory: String, CaseIterable, Codable, Hashable {

    case medical       = "Medical"
    case preparation   = "Preparation"
    case shopping      = "Shopping"
    case selfCare      = "Self-Care"
    case administrative = "Administrative"

    // MARK: Icon

    /// BloomIcons asset name representing this category.
    var icon: String {
        switch self {
        case .medical:        return BloomIcons.firstAid
        case .preparation:    return BloomIcons.checklist
        case .shopping:       return BloomIcons.checklist
        case .selfCare:       return BloomIcons.heartFilled
        case .administrative: return BloomIcons.document
        }
    }

    // MARK: Color

    /// Hex color string sourced from BloomColors, used for tinting category
    /// badges and icons in the UI.
    ///
    /// - Medical:        Soft Rose     `#F4A0B5`
    /// - Preparation:    Lavender      `#C7B8EA`
    /// - Shopping:       Peach         `#F9D5A7`
    /// - Self-Care:      Sage Green    `#A8D5BA`
    /// - Administrative: Luteal Blue   `#B8C9E8`
    var colorHex: String {
        switch self {
        case .medical:        return "#F4A0B5"
        case .preparation:    return "#C7B8EA"
        case .shopping:       return "#F9D5A7"
        case .selfCare:       return "#A8D5BA"
        case .administrative: return "#B8C9E8"
        }
    }
}

// MARK: - ChecklistItemData

/// A single actionable checklist item relevant from a specific gestational week.
struct ChecklistItemData: Identifiable, Codable, Hashable {

    /// Stable identifier for persistence and diffing.
    let id: String

    /// Short, action-oriented title displayed in the checklist row.
    let title: String

    /// One- to two-sentence description providing context or how-to guidance.
    let description: String

    /// SF Symbol name for the item's leading icon.
    let icon: String

    /// The gestational week from which this item becomes relevant.
    ///
    /// An item with `week = 12` appears in `items(for: week)` for all weeks ≥ 12.
    let week: Int

    /// Category for grouping and color theming.
    let category: ChecklistCategory

    // MARK: Init

    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        icon: String,
        week: Int,
        category: ChecklistCategory
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.week = week
        self.category = category
    }
}

// MARK: - ChecklistData

/// Static store of all pregnancy checklist items with query helpers.
///
/// Usage:
/// ```swift
/// // Show all tasks relevant up to the current week
/// let allSoFar = ChecklistData.items(for: currentWeek)
///
/// // Show only tasks newly unlocked this week (for a "New this week" section)
/// let thisWeek = ChecklistData.newItems(for: currentWeek)
/// ```
enum ChecklistData {

    // MARK: - All Items

    /// Complete list of checklist items, ordered by gestational week.
    static let items: [ChecklistItemData] = [

        // MARK: Week 4 — Earliest Actions

        ChecklistItemData(
            id: "confirm-pregnancy",
            title: "Confirm your pregnancy",
            description: "Take a home pregnancy test and, if positive, book a confirmation appointment with your GP or midwife as soon as possible.",
            icon: "plus-circle",
            week: 4,
            category: .medical
        ),

        ChecklistItemData(
            id: "prenatal-vitamins",
            title: "Start prenatal vitamins",
            description: "Take a daily supplement containing at least 400 mcg of folic acid. Folic acid in the first 12 weeks significantly reduces the risk of neural tube defects.",
            icon: "pill",
            week: 4,
            category: .medical
        ),

        ChecklistItemData(
            id: "stop-alcohol-smoking",
            title: "Stop alcohol and smoking",
            description: "No safe level of alcohol has been established during pregnancy. Stopping smoking immediately reduces risk of miscarriage, premature birth, and low birth weight.",
            icon: "stop-circle",
            week: 4,
            category: .selfCare
        ),

        ChecklistItemData(
            id: "review-medications",
            title: "Review all medications with your GP",
            description: "Some prescription and over-the-counter medications are not safe in pregnancy. Bring a list of everything you take — including supplements — to your GP.",
            icon: "checklist",
            week: 4,
            category: .medical
        ),

        ChecklistItemData(
            id: "calculate-due-date",
            title: "Calculate your estimated due date",
            description: "Your EDD is approximately 40 weeks from the first day of your last menstrual period (LMP). Use BloomHer's pregnancy tracker or an NHS due date calculator.",
            icon: "calendar-plus",
            week: 4,
            category: .administrative
        ),

        ChecklistItemData(
            id: "avoid-listeria-foods",
            title: "Learn pregnancy food safety guidelines",
            description: "Avoid raw or undercooked meat, unpasteurised dairy, high-mercury fish, and ready-to-eat deli meats. The NHS and ACOG provide up-to-date food safety lists.",
            icon: "nutrition",
            week: 4,
            category: .selfCare
        ),

        // MARK: Week 6

        ChecklistItemData(
            id: "book-booking-appointment",
            title: "Book your booking appointment",
            description: "Your first midwife 'booking' appointment (typically 8–10 weeks) covers your medical history, blood tests, and first scans. Book it now — slots fill quickly.",
            icon: "stethoscope",
            week: 6,
            category: .medical
        ),

        ChecklistItemData(
            id: "dental-checkup",
            title: "Schedule a dental check-up",
            description: "Pregnancy hormones can cause gum inflammation (pregnancy gingivitis). NHS dental care is free during pregnancy and for one year after the birth — take advantage of it.",
            icon: "stethoscope",
            week: 6,
            category: .medical
        ),

        ChecklistItemData(
            id: "nausea-management",
            title: "Establish a nausea management plan",
            description: "Identify what helps your nausea: ginger, small frequent meals, cold foods, vitamin B6. Speak to your GP about safe antiemetic options if symptoms are severe.",
            icon: "pulse",
            week: 6,
            category: .selfCare
        ),

        // MARK: Week 8

        ChecklistItemData(
            id: "first-trimester-blood-tests",
            title: "Attend booking appointment and blood tests",
            description: "Blood tests at your booking appointment check for blood type, anaemia, HIV, hepatitis B, syphilis, and immunity to rubella. These are essential baseline tests.",
            icon: "drop",
            week: 8,
            category: .medical
        ),

        ChecklistItemData(
            id: "book-dating-scan",
            title: "Book your dating (12-week) scan",
            description: "The dating scan at 11–14 weeks confirms your due date, checks for multiples, and measures the nuchal translucency for Down syndrome screening.",
            icon: "pulse",
            week: 8,
            category: .medical
        ),

        ChecklistItemData(
            id: "tell-partner-support-person",
            title: "Share the news with your support person",
            description: "Identify who your primary birth partner will be. Inform them early so they can support you through appointments, scans, and ultimately the birth.",
            icon: "person-plus",
            week: 8,
            category: .preparation
        ),

        ChecklistItemData(
            id: "lifestyle-audit",
            title: "Complete a lifestyle audit",
            description: "Review your caffeine intake (keep under 200 mg/day), sleep habits, exercise routine, and stress levels. Small changes now compound through pregnancy.",
            icon: "checkmark-seal",
            week: 8,
            category: .selfCare
        ),

        // MARK: Week 10

        ChecklistItemData(
            id: "nipt-nt-scan",
            title: "Arrange NIPT or NT screening",
            description: "Non-Invasive Prenatal Testing (NIPT) and the Nuchal Translucency scan are offered from 10–14 weeks. Discuss the options, costs, and results interpretation with your provider.",
            icon: "heart-filled",
            week: 10,
            category: .medical
        ),

        ChecklistItemData(
            id: "pregnancy-book-resources",
            title: "Choose a pregnancy book or resource",
            description: "A reliable pregnancy reference (e.g., 'What to Expect When You're Expecting', NHS's 'The Pregnancy Book', or the ACOG guide) helps normalise changes and prepare for appointments.",
            icon: "book",
            week: 10,
            category: .preparation
        ),

        ChecklistItemData(
            id: "start-journaling",
            title: "Start a pregnancy journal",
            description: "Recording your symptoms, milestones, emotions, and scan images creates a precious record. It can also be a useful symptom tracker to share with your midwife.",
            icon: "edit",
            week: 10,
            category: .selfCare
        ),

        // MARK: Week 12

        ChecklistItemData(
            id: "attend-dating-scan",
            title: "Attend your 12-week dating scan",
            description: "This scan dates your pregnancy precisely, identifies multiple pregnancies, and performs nuchal translucency measurement for chromosomal screening.",
            icon: "pulse",
            week: 12,
            category: .medical
        ),

        ChecklistItemData(
            id: "announce-pregnancy",
            title: "Announce your pregnancy",
            description: "After your dating scan confirms all is well, many couples choose to share the news with family and friends. There is no obligation — do what feels right for you.",
            icon: "bell",
            week: 12,
            category: .preparation
        ),

        ChecklistItemData(
            id: "register-with-midwife",
            title: "Confirm ongoing midwife care",
            description: "Ensure you are registered with a community midwife or obstetric team for your antenatal appointments through to delivery. Know who to call with concerns at any hour.",
            icon: "person-circle",
            week: 12,
            category: .medical
        ),

        ChecklistItemData(
            id: "begin-moisturising",
            title: "Begin daily belly moisturising",
            description: "Apply a fragrance-free oil or cream (coconut oil, shea butter, bio oil) daily to the abdomen, hips, and breasts. While stretch marks have a genetic component, moisturising supports skin elasticity.",
            icon: "drop",
            week: 12,
            category: .selfCare
        ),

        // MARK: Week 14

        ChecklistItemData(
            id: "tell-employer",
            title: "Notify your employer",
            description: "In the UK, you must notify your employer before 15 weeks prior to your due date to access full maternity rights. Check your employment contract and local legislation.",
            icon: "checklist",
            week: 14,
            category: .administrative
        ),

        ChecklistItemData(
            id: "maternity-rights-research",
            title: "Research your maternity rights and pay",
            description: "Understand your entitlement to Statutory Maternity Pay (SMP) or Maternity Allowance, shared parental leave, and any enhanced maternity benefits from your employer.",
            icon: "document",
            week: 14,
            category: .administrative
        ),

        ChecklistItemData(
            id: "start-antenatal-class-research",
            title: "Research antenatal education classes",
            description: "NHS antenatal classes, NCT courses, and private hypnobirthing courses often fill up 3–4 months in advance. Browse options now and book your preferred course.",
            icon: "yoga",
            week: 14,
            category: .preparation
        ),

        ChecklistItemData(
            id: "omega3-supplement",
            title: "Add omega-3 / DHA supplement",
            description: "DHA (docosahexaenoic acid) supports fetal brain and eye development. Aim for 200–300 mg DHA per day from oily fish or a pregnancy-safe algae-based supplement.",
            icon: "nutrition",
            week: 14,
            category: .medical
        ),

        // MARK: Week 16

        ChecklistItemData(
            id: "buy-maternity-clothes",
            title: "Invest in maternity clothing",
            description: "Most women find regular waistbands uncomfortable from week 16. A few versatile maternity basics — jeans, leggings, tops, and a supportive bra — will see you through to birth.",
            icon: "checklist",
            week: 16,
            category: .shopping
        ),

        ChecklistItemData(
            id: "pregnancy-support-belt",
            title: "Consider a maternity support belt",
            description: "A support belt can significantly relieve lower back and pelvic girdle pain as your bump grows. Ask your midwife or physiotherapist which type is appropriate for you.",
            icon: "figure-stand",
            week: 16,
            category: .shopping
        ),

        ChecklistItemData(
            id: "pelvic-floor-exercises",
            title: "Start daily pelvic floor exercises",
            description: "Kegel exercises performed throughout pregnancy strengthen the muscles that support the uterus, bladder, and bowel, and significantly speed postpartum recovery.",
            icon: "yoga",
            week: 16,
            category: .selfCare
        ),

        ChecklistItemData(
            id: "hospital-tour-booking",
            title: "Book a hospital or birth centre tour",
            description: "Familiarise yourself with your chosen birth environment — where to park, where to go when in labour, the facilities available, and the ethos of the unit.",
            icon: "person",
            week: 16,
            category: .preparation
        ),

        // MARK: Week 18

        ChecklistItemData(
            id: "book-anomaly-scan",
            title: "Book your anatomy (anomaly) scan",
            description: "The anomaly scan at 18–21 weeks is a detailed ultrasound assessing fetal anatomy, growth, placenta position, and amniotic fluid. Ensure it is booked.",
            icon: "pulse",
            week: 18,
            category: .medical
        ),

        ChecklistItemData(
            id: "side-sleeping-pillow",
            title: "Buy a pregnancy pillow",
            description: "From mid-pregnancy, sleeping on your side (preferably left) is recommended. A full-body pregnancy pillow significantly improves comfort and sleep quality.",
            icon: "moon-stars",
            week: 18,
            category: .shopping
        ),

        ChecklistItemData(
            id: "begin-kick-awareness",
            title: "Develop awareness of fetal movements",
            description: "First-time mothers typically feel movements (quickening) between 18–22 weeks. Begin to notice your baby's normal movement pattern — this is a key safety habit.",
            icon: "heart-filled",
            week: 18,
            category: .medical
        ),

        // MARK: Week 20

        ChecklistItemData(
            id: "attend-anomaly-scan",
            title: "Attend your anatomy scan",
            description: "This detailed scan at the halfway mark assesses all major organ systems. Ask the sonographer about placenta position and — if you want to know — your baby's sex.",
            icon: "pulse",
            week: 20,
            category: .medical
        ),

        ChecklistItemData(
            id: "birth-plan-start",
            title: "Begin drafting your birth plan",
            description: "A birth plan documents your preferences for pain relief, fetal monitoring, labour environment, birth partner, delivery type, and newborn procedures. Start with broad preferences now.",
            icon: "document",
            week: 20,
            category: .preparation
        ),

        ChecklistItemData(
            id: "book-antenatal-class",
            title: "Book your antenatal class",
            description: "Enrol in your chosen antenatal education course now. Classes typically run over several weeks starting from around 28–32 weeks, so booking at 20 weeks is ideal.",
            icon: "graduation",
            week: 20,
            category: .preparation
        ),

        ChecklistItemData(
            id: "nursery-planning",
            title: "Begin nursery planning",
            description: "Consider the layout and essential furniture for your baby's sleep space. If redecorating or painting, choose low-VOC paints and ensure good ventilation — do not do heavy work yourself.",
            icon: "selfcare-creative",
            week: 20,
            category: .preparation
        ),

        ChecklistItemData(
            id: "research-infant-feeding",
            title: "Research infant feeding options",
            description: "Gather information about breastfeeding, formula feeding, and combination feeding. The WHO recommends exclusive breastfeeding for 6 months, but the right choice is the one that works for your family.",
            icon: "heart-filled",
            week: 20,
            category: .preparation
        ),

        // MARK: Week 22

        ChecklistItemData(
            id: "research-pram-system",
            title: "Research pram and travel system",
            description: "Research pram, pushchair, and travel system options. Consider compatibility with your car, home storage, and lifestyle. Lead times on popular brands can be 8–16 weeks.",
            icon: "yoga",
            week: 22,
            category: .shopping
        ),

        ChecklistItemData(
            id: "establish-kick-counting",
            title: "Establish a daily movement check habit",
            description: "From week 24, monitor your baby's movements daily. If you notice a change in your baby's usual pattern, contact your midwife the same day — do not wait.",
            icon: "hand-tap",
            week: 22,
            category: .medical
        ),

        ChecklistItemData(
            id: "maternity-leave-paperwork",
            title: "Submit maternity leave notification",
            description: "Complete and submit your formal maternity leave notification to your employer. In the UK this is typically done via a MAT B1 form provided by your midwife at 20 weeks.",
            icon: "note",
            week: 22,
            category: .administrative
        ),

        // MARK: Week 24

        ChecklistItemData(
            id: "glucose-screening",
            title: "Attend gestational diabetes screening",
            description: "The glucose challenge test (GCT) or oral glucose tolerance test (OGTT) is offered at 24–28 weeks to screen for gestational diabetes. Attend even if you feel well.",
            icon: "first-aid",
            week: 24,
            category: .medical
        ),

        ChecklistItemData(
            id: "research-childcare",
            title: "Begin researching childcare",
            description: "Quality nursery places and childminders in popular areas can have waiting lists of 12–18 months. Begin researching options and registering interest, even before the birth.",
            icon: "person",
            week: 24,
            category: .administrative
        ),

        // MARK: Week 26

        ChecklistItemData(
            id: "birth-plan-draft",
            title: "Write a full draft birth plan",
            description: "Detail your preferences for: environment (lighting, music), pain relief (epidural, gas and air, water birth), monitoring, third stage (active vs. physiological), and newborn procedures (vitamin K, skin-to-skin).",
            icon: "document",
            week: 26,
            category: .preparation
        ),

        ChecklistItemData(
            id: "rhesus-negative-anti-d",
            title: "Rh-negative mothers: arrange Anti-D injection",
            description: "If you are Rh-negative, an anti-D immunoglobulin injection is offered at 28 weeks (and again after birth if baby is Rh-positive). Ensure your appointment is scheduled.",
            icon: "first-aid",
            week: 26,
            category: .medical
        ),

        ChecklistItemData(
            id: "prepare-colostrum-collection",
            title: "Ask about antenatal colostrum harvesting",
            description: "Antenatal colostrum expression (from 36 weeks for low-risk pregnancies) allows you to collect and freeze first milk before birth. Ask your midwife if this is appropriate for you.",
            icon: "drop",
            week: 26,
            category: .preparation
        ),

        // MARK: Week 28

        ChecklistItemData(
            id: "anti-d-injection",
            title: "Attend 28-week Anti-D appointment (if Rh-negative)",
            description: "The routine Anti-D injection at 28 weeks prevents sensitisation if any small amount of fetal blood has entered your bloodstream.",
            icon: "first-aid",
            week: 28,
            category: .medical
        ),

        ChecklistItemData(
            id: "start-hospital-bag-list",
            title: "Create your hospital bag checklist",
            description: "Begin listing what you will need for labour, delivery, and the postnatal stay — for you and your baby. Your hospital bag should be packed and ready by 36 weeks.",
            icon: "checklist",
            week: 28,
            category: .preparation
        ),

        ChecklistItemData(
            id: "third-trimester-blood-tests",
            title: "Attend third trimester blood tests",
            description: "Blood tests at approximately 28 weeks recheck your haemoglobin levels and screen for anaemia. Iron supplementation may be recommended.",
            icon: "drop",
            week: 28,
            category: .medical
        ),

        ChecklistItemData(
            id: "tour-hospital",
            title: "Tour your birth unit",
            description: "Visit your hospital or birth centre before you are in labour — know where to park, which entrance to use in an emergency, and what the environment looks like.",
            icon: "graduation",
            week: 28,
            category: .preparation
        ),

        // MARK: Week 30

        ChecklistItemData(
            id: "freezer-meal-prep-start",
            title: "Begin batch cooking and freezing meals",
            description: "Preparing frozen meals in advance is one of the most practical things you can do for the postpartum period. Aim for 20+ portions of nutritious, reheatable meals.",
            icon: "checklist",
            week: 30,
            category: .preparation
        ),

        ChecklistItemData(
            id: "postpartum-support-plan",
            title: "Plan your postpartum support",
            description: "Discuss with your partner and family who will help in the first 6 weeks. Consider whether you will have visitors, who will cook, and when your partner's parental leave begins.",
            icon: "yoga",
            week: 30,
            category: .preparation
        ),

        ChecklistItemData(
            id: "research-newborn-care",
            title: "Attend or watch newborn care resources",
            description: "Learn the basics of nappy changing, bathing, safe sleep (SIDS prevention), swaddling, and newborn cues before the birth — not in the first sleep-deprived night.",
            icon: "yoga",
            week: 30,
            category: .preparation
        ),

        // MARK: Week 32

        ChecklistItemData(
            id: "pack-hospital-bag",
            title: "Pack your hospital bag",
            description: "Pack bags for labour, delivery, and the postnatal ward. Essentials: hospital notes, birth plan, phone charger, comfortable clothing, toiletries, snacks, and your baby's first outfit.",
            icon: "checklist",
            week: 32,
            category: .shopping
        ),

        ChecklistItemData(
            id: "purchase-baby-essentials",
            title: "Purchase newborn essentials",
            description: "Ensure you have: newborn nappies, wipes, onesies (sizes newborn and 0-3M), cellular blankets, a safe sleep surface (crib or Moses basket with firm mattress), and a first aid kit.",
            icon: "checklist",
            week: 32,
            category: .shopping
        ),

        ChecklistItemData(
            id: "attend-antenatal-class",
            title: "Complete your antenatal class",
            description: "Attend all sessions of your booked antenatal or hypnobirthing course. These classes provide critical knowledge about labour, birth, and the early postnatal period.",
            icon: "person-plus",
            week: 32,
            category: .preparation
        ),

        ChecklistItemData(
            id: "breastfeeding-support",
            title: "Connect with breastfeeding support resources",
            description: "Find your local breastfeeding support group, La Leche League chapter, or a certified lactation consultant (IBCLC) now — having these contacts ready before birth is invaluable.",
            icon: "heart-filled",
            week: 32,
            category: .preparation
        ),

        // MARK: Week 34

        ChecklistItemData(
            id: "choose-paediatrician",
            title: "Choose a paediatrician or GP for your baby",
            description: "Register your baby with a GP practice before the birth so the newborn check and early vaccinations are seamlessly arranged when the time comes.",
            icon: "stethoscope",
            week: 34,
            category: .administrative
        ),

        ChecklistItemData(
            id: "install-car-seat",
            title: "Purchase and install infant car seat",
            description: "An infant car seat is legally required to leave the hospital by car. Have your seat fitted by a certified technician and ensure it suits your car before the birth.",
            icon: "map-pin",
            week: 34,
            category: .shopping
        ),

        ChecklistItemData(
            id: "perineal-massage",
            title: "Begin perineal massage",
            description: "Evidence supports daily perineal massage from 34–35 weeks in reducing perineal trauma at birth. Ask your midwife for technique guidance or use a validated resource.",
            icon: BloomIcons.sparkles,
            week: 34,
            category: .selfCare
        ),

        ChecklistItemData(
            id: "group-b-strep-test",
            title: "Consider Group B Strep (GBS) testing",
            description: "GBS testing is not universally offered on the NHS but is available privately (weeks 35–37). Discuss the implications of a positive result with your provider, as it affects intrapartum antibiotic guidance.",
            icon: "first-aid",
            week: 34,
            category: .medical
        ),

        ChecklistItemData(
            id: "confirm-birth-partner",
            title: "Confirm birth partner plan and knowledge",
            description: "Ensure your birth partner has read your birth plan, knows the route to the hospital, and understands their role. Practice your comfort techniques together.",
            icon: "person-circle",
            week: 34,
            category: .preparation
        ),

        // MARK: Week 36

        ChecklistItemData(
            id: "finalise-birth-plan",
            title: "Finalise and share your birth plan",
            description: "Complete your birth preferences document. Give copies to your midwife, include one in your hospital bag, and ensure your birth partner has their own copy.",
            icon: "checkmark-circle",
            week: 36,
            category: .preparation
        ),

        ChecklistItemData(
            id: "gbs-result-discussion",
            title: "Discuss GBS result with your provider",
            description: "If you were tested for Group B Strep, ensure your result is in your notes and your birth plan reflects any agreed treatment (e.g., intravenous antibiotics in labour).",
            icon: "note",
            week: 36,
            category: .medical
        ),

        ChecklistItemData(
            id: "plan-labour-at-home",
            title: "Plan your early labour at home",
            description: "Discuss with your midwife when to go to hospital (typically contractions 5 minutes apart, lasting 60 seconds, for 1 hour). Plan what to do in early labour: rest, eat, distract yourself.",
            icon: "person",
            week: 36,
            category: .preparation
        ),

        ChecklistItemData(
            id: "antenatal-colostrum",
            title: "Begin antenatal colostrum expression (if advised)",
            description: "If recommended by your midwife, begin collecting colostrum using a small syringe from 36 weeks. Store collected colostrum in labelled syringes in the freezer.",
            icon: "thermometer",
            week: 36,
            category: .medical
        ),

        ChecklistItemData(
            id: "newborn-photography",
            title: "Research newborn photography (optional)",
            description: "If you would like professional newborn photographs, book a photographer now — popular newborn photographers in your area may already be fully booked for your due month.",
            icon: "camera-plus",
            week: 36,
            category: .preparation
        ),

        // MARK: Week 37

        ChecklistItemData(
            id: "confirm-car-seat-installation",
            title: "Confirm car seat is installed correctly",
            description: "Have your infant car seat installation checked by a certified technician if you have not already. Many fire stations and children's centres offer free checks.",
            icon: "checkmark-shield",
            week: 37,
            category: .shopping
        ),

        ChecklistItemData(
            id: "know-labour-signs",
            title: "Review the signs of labour",
            description: "True labour: contractions that become longer, stronger, and closer together; a 'show' (blood-streaked mucus); waters breaking. Know when to call your midwife and when to go to hospital.",
            icon: "warning",
            week: 37,
            category: .preparation
        ),

        ChecklistItemData(
            id: "install-nightlight",
            title: "Prepare the nursery for night feeds",
            description: "Install a dim nightlight in the nursery or bedroom that is bright enough to see safely but dim enough to preserve your night vision and avoid fully waking the baby.",
            icon: BloomIcons.sparkles,
            week: 37,
            category: .shopping
        ),

        // MARK: Week 38

        ChecklistItemData(
            id: "register-birth-plan-with-hospital",
            title: "Ensure your hospital has your birth plan on file",
            description: "Call your maternity unit to confirm your details, birth preferences, and any specific medical notes (e.g., GBS positive, allergy to medications) are in your file.",
            icon: "plus",
            week: 38,
            category: .administrative
        ),

        ChecklistItemData(
            id: "postpartum-care-kit",
            title: "Assemble a postpartum recovery kit",
            description: "Prepare: maternity pads, disposable underwear, perineal spray, ice packs, nipple cream (lanolin), nipple pads, and comfortable loose clothing for the fourth trimester.",
            icon: "first-aid",
            week: 38,
            category: .shopping
        ),

        ChecklistItemData(
            id: "charge-devices",
            title: "Charge and pack all devices for the hospital",
            description: "Ensure your phone and camera are charged, with chargers in your hospital bag. Download any apps you plan to use (contraction timer, newborn tracker) ahead of time.",
            icon: "bolt",
            week: 38,
            category: .preparation
        ),

        // MARK: Week 39

        ChecklistItemData(
            id: "discuss-induction-options",
            title: "Discuss induction at your 39-40 week appointment",
            description: "Your provider will discuss induction of labour (IOL) options and timing, particularly if you approach or pass your due date. Ask questions and understand your choices.",
            icon: "person-circle",
            week: 39,
            category: .medical
        ),

        ChecklistItemData(
            id: "membrane-sweep",
            title: "Ask about a membrane sweep",
            description: "A membrane sweep is offered from 39 weeks onwards to encourage labour to begin naturally, avoiding or delaying medical induction. It can be performed at your antenatal appointment.",
            icon: "clock-history",
            week: 39,
            category: .medical
        ),

        ChecklistItemData(
            id: "finalise-name-shortlist",
            title: "Finalise your baby name shortlist",
            description: "You have time to decide after meeting your baby, but having a shortlist reduces one decision in the early haze of new parenthood.",
            icon: "star-filled",
            week: 39,
            category: .preparation
        ),

        // MARK: Week 40

        ChecklistItemData(
            id: "birth-registration-research",
            title: "Research how to register the birth",
            description: "In the UK, you must register your baby's birth within 42 days. Look up your local register office and the documents required (both parents' IDs, hospital birth notification).",
            icon: "document",
            week: 40,
            category: .administrative
        ),

        ChecklistItemData(
            id: "monitor-movement-at-term",
            title: "Continue daily fetal movement monitoring",
            description: "Movement does not slow down at term. If you notice a change in your baby's usual pattern, contact your maternity unit immediately — do not wait until the next day.",
            icon: "pulse",
            week: 40,
            category: .medical
        ),

        ChecklistItemData(
            id: "rest-and-self-care-at-term",
            title: "Prioritise rest and nourishment",
            description: "Labour is a physical marathon. Eat nutritious meals, stay hydrated, and rest whenever possible. Trust your preparation — you are ready.",
            icon: BloomIcons.sparkles,
            week: 40,
            category: .selfCare
        )
    ]

    // MARK: - Query Methods

    /// Returns all checklist items that are relevant up to and including the given week.
    ///
    /// This cumulative view is appropriate for a main checklist screen where the user
    /// sees all tasks they should be working on so far.
    ///
    /// - Parameter week: The current gestational week (1–40).
    /// - Returns: Items where `item.week <= week`, sorted by week then category.
    static func items(for week: Int) -> [ChecklistItemData] {
        items.filter { $0.week <= week }
    }

    /// Returns only the items that become newly relevant in the given week.
    ///
    /// Use this to power a "New this week" section or push notification.
    ///
    /// - Parameter week: The current gestational week (1–40).
    /// - Returns: Items where `item.week == week`.
    static func newItems(for week: Int) -> [ChecklistItemData] {
        items.filter { $0.week == week }
    }

    /// Returns all items belonging to the given category, filtered up to the given week.
    ///
    /// - Parameters:
    ///   - category: The `ChecklistCategory` to filter by.
    ///   - week: The current gestational week (1–40).
    /// - Returns: Filtered and sorted array of matching items.
    static func items(for category: ChecklistCategory, upToWeek week: Int) -> [ChecklistItemData] {
        items.filter { $0.category == category && $0.week <= week }
    }

    /// Returns items grouped by trimester, filtered up to the given week.
    ///
    /// - Parameter week: The current gestational week (1–40).
    /// - Returns: Dictionary keyed by trimester (1, 2, 3) with arrays of relevant items.
    static func itemsByTrimester(upToWeek week: Int) -> [Int: [ChecklistItemData]] {
        let relevant = items(for: week)
        return Dictionary(grouping: relevant) { item -> Int in
            switch item.week {
            case 1...12: return 1
            case 13...26: return 2
            default:     return 3
            }
        }
    }
}
