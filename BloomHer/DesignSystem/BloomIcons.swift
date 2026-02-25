//
//  BloomIcons.swift
//  BloomHer
//
//  Centralized registry of ALL custom icon asset names.
//  Zero SF Symbols anywhere in the app — every icon is a custom
//  asset from icons8.com downloaded into Assets.xcassets/Icons/.
//
//  Usage:
//    Image(BloomIcons.heart)
//        .resizable()
//        .scaledToFit()
//        .frame(width: 24, height: 24)
//
//  Or use the BloomImage convenience view:
//    BloomImage(BloomIcons.heart, size: 24)
//    BloomImage(BloomIcons.calendar, size: 20, color: BloomColors.primaryRose)
//

import SwiftUI

// MARK: - BloomIcons

enum BloomIcons {

    // MARK: - Tab Bar
    static let tabHome          = "tab-home"
    static let tabCalendar      = "tab-calendar"
    static let tabWellness      = "tab-wellness"
    static let tabInsights      = "tab-insights"
    static let tabProfile       = "tab-profile"

    // MARK: - UI Controls
    static let checkmark        = "checkmark"
    static let checkmarkCircle  = "checkmark-circle"
    static let checkmarkSeal    = "checkmark-seal"
    static let checkmarkShield  = "checkmark-shield"
    static let xmark            = "xmark"
    static let xmarkCircle      = "xmark-circle"
    static let plus             = "plus"
    static let plusCircle       = "plus-circle"
    static let minusCircle      = "minus-circle"
    static let plusMinus        = "plus-minus"
    static let star             = "star"
    static let starFilled       = "star-filled"
    static let heart            = "heart"
    static let heartFilled      = "heart-filled"
    static let chevronRight     = "chevron-right"
    static let chevronLeft      = "chevron-left"
    static let chevronDown      = "chevron-down"
    static let chevronUp        = "chevron-up"
    static let chevronRightCircle = "chevron-right-circle"
    static let chevronLeftCircle  = "chevron-left-circle"

    // MARK: - Navigation & Actions
    static let refresh          = "refresh"
    static let share            = "share"
    static let shareCircle      = "share-circle"
    static let trash            = "trash"
    static let edit             = "edit"
    static let externalLink     = "external-link"
    static let swap             = "swap"
    static let arrowUpCircle    = "arrow-up-circle"
    static let handTap          = "hand-tap"

    // MARK: - Status & Alerts
    static let errorCircle      = "error-circle"
    static let warning          = "warning"
    static let info             = "info"
    static let target           = "target"
    static let stopCircle       = "stop-circle"

    // MARK: - Calendar & Time
    static let calendar         = "calendar"
    static let calendarClock    = "calendar-clock"
    static let calendarPlus     = "calendar-plus"
    static let calendarCheck    = "calendar-check"
    static let clock            = "clock"
    static let clockHistory     = "clock-history"
    static let timer            = "timer"
    static let forwardEnd       = "forward-end"

    // MARK: - Health & Medical
    static let stethoscope      = "stethoscope"
    static let thermometer      = "thermometer"
    static let firstAid         = "first-aid"
    static let scales           = "scales"
    static let pill             = "pill"
    static let ecg              = "ecg"
    static let pulse            = "pulse"
    static let heartMonitor     = "heart-monitor"
    static let drop             = "drop"

    // MARK: - Wellness & Fitness
    static let yoga             = "yoga"
    static let figureStand      = "figure-stand"
    static let meditation       = "meditation"
    static let flame            = "flame"
    static let bolt             = "bolt"
    static let moonStars        = "moon-stars"
    static let sparkles         = "sparkles"
    static let flower           = "flower"
    static let leaf             = "leaf"

    // MARK: - People & Social
    static let person           = "person"
    static let personPlus       = "person-plus"
    static let personCircle     = "person-circle"
    static let faceSmiling      = "face-smiling"

    // MARK: - Documents & Media
    static let book             = "book"
    static let books            = "books"
    static let document         = "document"
    static let note             = "note"
    static let checklist        = "checklist"
    static let listBullet       = "list-bullet"
    static let listNumber       = "list-number"
    static let cameraPlus       = "camera-plus"

    // MARK: - Charts & Analytics
    static let chartBar         = "chart-bar"
    static let chartLine        = "chart-line"
    static let chartCombo       = "chart-combo"
    static let chartReport      = "chart-report"

    // MARK: - Settings & System
    static let bell             = "bell"
    static let lockShield       = "lock-shield"
    static let icloud           = "icloud"
    static let wifi             = "wifi"
    static let graduation       = "graduation"
    static let colorDropper     = "color-dropper"
    static let mapPin           = "map-pin"
    static let play             = "play"
    static let pause            = "pause"

    // MARK: - AI Assistant
    static let bloomAI          = "bloom-ai"

    // MARK: - Brand / Dove
    static let dove             = "dove"
    static let doveHero         = "dove-hero"

    // MARK: - Hero Images (Gemini-generated)
    static let heroYoga         = "hero-yoga"
    static let heroInsights     = "hero-insights"
    static let heroGratitude    = "hero-gratitude"
    static let heroBreathing    = "hero-breathing"
    static let heroWellness     = "hero-wellness"
    static let heroOnboarding   = "hero-onboarding"
    static let heroCalendar     = "hero-calendar"

    // MARK: - Mode Icons
    static let iconCycle        = "icon-cycle"
    static let iconPregnant     = "iconpreg"
    static let iconTTC          = "icon-ttc"

    // MARK: - Cycle Phase Icons
    static let phaseMenstrual   = "phase-menstrual"
    static let phaseFollicular  = "phase-follicular"
    static let phaseOvulation   = "phase-ovulation"
    static let phaseLuteal      = "phase-luteal"

    // MARK: - Feature Icons: Wellness
    static let hydration        = "hydration"
    static let breathing        = "breathing"
    static let nutrition        = "nutrition"
    static let affirmations     = "affirmations"
    static let supplements      = "supplements"
    static let gratitude        = "gratitude"

    // MARK: - Feature Icons: Yoga
    static let poseLibrary      = "pose-library"
    static let pelvicFloor      = "pelvic-floor"

    // MARK: - Feature Icons: TTC
    static let bbtChart         = "bbt-chart"
    static let opkTest          = "opk-test"
    static let conceptionTips   = "conception-tips"
    static let fertileWindow    = "fertile-window"

    // MARK: - Feature Icons: Pregnancy
    static let kickCounter      = "kick-counter"
    static let contractionTimer = "contraction-timer"
    static let weightTracking   = "weight-tracking"
    static let appointments     = "appointments"

    // MARK: - Self-Care Categories
    static let selfcareRelaxation  = "selfcare-relaxation"
    static let selfcareMovement    = "selfcare-movement"
    static let selfcareMindfulness = "selfcare-mindfulness"
    static let selfcareSocial      = "selfcare-social"
    static let selfcareCreative    = "selfcare-creative"

    // MARK: - Hero Illustration
    static let heroIllustration    = "hero-illustration"

    // MARK: - Kawaii Period / Cycle Icons
    static let periodUterus        = "period-uterus"
    static let periodBloodDrop     = "period-blood-drop"
    static let periodMoodCloud     = "period-mood-cloud"
    static let periodCozyTea       = "period-cozy-tea"
    static let periodCalendar      = "period-period-calendar"
    static let periodPillBottle    = "period-pill-bottle"
    static let periodLoveLetter    = "period-love-letter"
    static let periodComfortRibbon = "period-comfort-ribbon"

    // MARK: - Kawaii Pregnancy Icons
    static let pregTestStick       = "preg-test-stick"
    static let pregPregnantWoman   = "preg-pregnant-woman"
    static let pregStorkBundle     = "preg-stork-bundle"
    static let pregStorkStanding   = "preg-stork-standing"
    static let pregBabyBottle      = "preg-baby-bottle"
    static let pregHeartBaby       = "preg-heart-baby"
    static let pregPacifierBlue    = "preg-pacifier-blue"
    static let pregBabyBottleSmall = "preg-baby-bottle-small"
    static let pregPacifierPink    = "preg-pacifier-pink"
    static let pregBabyOnesie      = "preg-baby-onesie"
    static let pregOnesieHanger    = "preg-onesie-hanger"
    static let pregUltrasound      = "preg-ultrasound"
    static let pregBabyCradle      = "preg-baby-cradle"
    static let pregBabyFace        = "preg-baby-face"
    static let pregBabyFootprints  = "preg-baby-footprints"

    // MARK: - Kawaii TTC Icons
    static let ttcFertilityCalendar = "ttc-fertility-calendar"
    static let ttcSperm             = "ttc-sperm"
    static let ttcFamilyHeart       = "ttc-family-heart"
    static let ttcCaringHands       = "ttc-caring-hands"
    static let ttcStorkBundle       = "ttc-stork-bundle"
    static let ttcBabyBib           = "ttc-baby-bib"
    static let ttcTeapot            = "ttc-teapot"
    static let ttcThermometer       = "ttc-thermometer"
    static let ttcCalendarQuestion  = "ttc-calendar-question"
    static let ttcTestStick         = "ttc-test-stick"
    static let ttcBabyOnesie        = "ttc-baby-onesie"
    static let ttcUltrasound        = "ttc-ultrasound"
    static let ttcCoupleFemale      = "ttc-couple-female"
    static let ttcCoupleMixed       = "ttc-couple-mixed"
    static let ttcPlantGrowing      = "ttc-plant-growing"

    // MARK: - Template Icons Set

    /// Icons that must render in template mode (UI controls, navigation arrows, etc.)
    /// All other icons should render in original mode to show full icons8 color.
    static let templateIcons: Set<String> = [
        checkmark, checkmarkCircle, checkmarkSeal, checkmarkShield,
        xmark, xmarkCircle,
        plus, plusCircle, minusCircle, plusMinus,
        chevronRight, chevronLeft, chevronDown, chevronUp,
        chevronRightCircle, chevronLeftCircle,
        refresh, share, shareCircle, trash, edit, externalLink, swap,
        arrowUpCircle, handTap,
        errorCircle, warning, info, target, stopCircle,
        play, pause, forwardEnd,
        star, starFilled,
        listBullet, listNumber,
    ]

    /// Returns true if this icon should use `.renderingMode(.template)`.
    static func isTemplate(_ name: String) -> Bool {
        templateIcons.contains(name)
    }
}

// MARK: - BloomImage

/// A convenience view that renders a BloomIcons asset at a given size.
///
/// Replaces `Image(systemName:)` everywhere in the app.
/// Supports optional color tinting via `.renderingMode(.template)`.
///
/// ```swift
/// // Standard (full color from icons8):
/// BloomImage(BloomIcons.heart, size: 24)
///
/// // Tinted (single color):
/// BloomImage(BloomIcons.calendar, size: 20, color: BloomColors.primaryRose)
///
/// // Large feature icon:
/// BloomImage(BloomIcons.yoga, size: 36)
/// ```
struct BloomImage: View {
    let name: String
    var size: CGFloat = 24
    var color: Color? = nil

    init(_ name: String, size: CGFloat = 24, color: Color? = nil) {
        self.name = name
        self.size = size
        self.color = color
    }

    var body: some View {
        if let color {
            Image(name)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundStyle(color)
        } else {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
}
