//
//  WidgetDataProvider.swift
//  BloomHerWidget
//
//  Self-contained data layer for the BloomHer widget extension.
//
//  Reads from the shared App Group UserDefaults suite so that the main app
//  can push updated values and WidgetKit can pick them up on the next
//  timeline refresh without requiring any direct target dependency.
//
//  App Group identifier: group.com.bloomher.shared
//
//  Keys written by the main app:
//    Cycle:
//      "widget.cycleDay"             Int
//      "widget.cycleLength"          Int
//      "widget.phase"                String  (WidgetCyclePhase raw value)
//      "widget.daysUntilNextPeriod"  Int     (optional — absent when unknown)
//      "widget.cycleLastUpdated"     Double  (timeIntervalSinceReferenceDate)
//
//    Pregnancy:
//      "widget.pregnancyWeek"        Int
//      "widget.trimester"            Int
//      "widget.daysUntilDue"         Int
//      "widget.babySize"             String
//      "widget.pregnancyLastUpdated" Double
//
//    Water:
//      "widget.waterIntakeMl"        Int
//      "widget.waterGoalMl"          Int
//      "widget.waterLastUpdated"     Double
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: - Color(hex:) — self-contained, no main-target import needed

extension Color {
    /// Creates a `Color` from a 6- or 8-character hex string (with or without `#`).
    init(widgetHex hex: String) {
        let normalized = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))

        var rgbaValue: UInt64 = 0
        Scanner(string: normalized).scanHexInt64(&rgbaValue)

        let r, g, b, a: Double
        switch normalized.count {
        case 6:
            r = Double((rgbaValue & 0xFF0000) >> 16) / 255.0
            g = Double((rgbaValue & 0x00FF00) >> 8)  / 255.0
            b = Double( rgbaValue & 0x0000FF)         / 255.0
            a = 1.0
        case 8:
            r = Double((rgbaValue & 0xFF000000) >> 24) / 255.0
            g = Double((rgbaValue & 0x00FF0000) >> 16) / 255.0
            b = Double((rgbaValue & 0x0000FF00) >> 8)  / 255.0
            a = Double( rgbaValue & 0x000000FF)         / 255.0
        default:
            r = 0; g = 0; b = 0; a = 0
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Widget Brand Colors

/// Self-contained BloomHer palette used exclusively by the widget extension.
/// All values are hardcoded to avoid any dependency on the main app target.
enum WidgetColors {
    // Brand
    static let primaryRose    = Color(widgetHex: "#F4A0B5")
    static let primaryRoseDark = Color(widgetHex: "#E88B9C")
    static let sageGreen      = Color(widgetHex: "#A8D5BA")
    static let accentLavender = Color(widgetHex: "#C7B8EA")
    static let accentPeach    = Color(widgetHex: "#F9D5A7")

    // Backgrounds
    static let creamBackground = Color(widgetHex: "#FFF8F5")
    static let darkBackground  = Color(widgetHex: "#1E1520")
    static let darkSurface     = Color(widgetHex: "#2A1F2E")

    // Text
    static let textPrimaryLight  = Color(widgetHex: "#3D2C2E")
    static let textPrimaryDark   = Color(widgetHex: "#F5EEF0")

    // Phase accent colors
    static let menstrualColor  = Color(widgetHex: "#E88B9C")
    static let follicularColor = Color(widgetHex: "#A8D5BA")
    static let ovulationColor  = Color(widgetHex: "#F9D5A7")
    static let lutealColor     = Color(widgetHex: "#B8C9E8")

    // Water
    static let waterBlue       = Color(widgetHex: "#7EC8E3")
    static let waterBlueDark   = Color(widgetHex: "#5AAECC")
}

// MARK: - WidgetCyclePhase

/// Mirror of the main app's `CyclePhase` — defined here so the widget
/// extension has no compile-time dependency on the main target.
enum WidgetCyclePhase: String, Codable, CaseIterable {
    case menstrual
    case follicular
    case ovulation
    case luteal

    var displayName: String {
        switch self {
        case .menstrual:  return "Menstrual"
        case .follicular: return "Follicular"
        case .ovulation:  return "Ovulation"
        case .luteal:     return "Luteal"
        }
    }

    var icon: String {
        switch self {
        case .menstrual:  return "drop.fill"
        case .follicular: return "leaf.fill"
        case .ovulation:  return "circle.fill"
        case .luteal:     return "moon.fill"
        }
    }

    /// The phase accent color. Hardcoded hex values avoid any main-target import.
    var color: Color {
        switch self {
        case .menstrual:  return WidgetColors.menstrualColor
        case .follicular: return WidgetColors.follicularColor
        case .ovulation:  return WidgetColors.ovulationColor
        case .luteal:     return WidgetColors.lutealColor
        }
    }

    /// A lighter tint of the phase color, used for gradient backgrounds.
    var lightColor: Color {
        switch self {
        case .menstrual:  return Color(widgetHex: "#F9C5CE")
        case .follicular: return Color(widgetHex: "#D4EDE0")
        case .ovulation:  return Color(widgetHex: "#FDEECE")
        case .luteal:     return Color(widgetHex: "#DCE8F7")
        }
    }

    /// Short description used in medium-size widgets.
    var shortDescription: String {
        switch self {
        case .menstrual:  return "Period phase"
        case .follicular: return "Energy rising"
        case .ovulation:  return "Peak fertility"
        case .luteal:     return "Wind-down phase"
        }
    }
}

// MARK: - Data Transfer Structs

struct WidgetCycleData {
    let cycleDay: Int
    let cycleLength: Int
    let phase: WidgetCyclePhase
    let daysUntilNextPeriod: Int?
    let lastUpdated: Date

    /// The fraction of the cycle completed (0.0–1.0).
    var cycleProgress: Double {
        guard cycleLength > 0 else { return 0 }
        return min(1.0, Double(cycleDay) / Double(cycleLength))
    }

    /// Placeholder/fallback data used when no real data exists yet.
    static let placeholder = WidgetCycleData(
        cycleDay: 14,
        cycleLength: 28,
        phase: .follicular,
        daysUntilNextPeriod: 14,
        lastUpdated: Date()
    )
}

struct WidgetPregnancyData {
    let currentWeek: Int
    let trimester: Int
    let daysUntilDue: Int
    let babySize: String
    let lastUpdated: Date

    var trimesterLabel: String {
        switch trimester {
        case 1: return "First Trimester"
        case 2: return "Second Trimester"
        default: return "Third Trimester"
        }
    }

    static let placeholder = WidgetPregnancyData(
        currentWeek: 20,
        trimester: 2,
        daysUntilDue: 140,
        babySize: "Banana",
        lastUpdated: Date()
    )
}

struct WidgetWaterData {
    let intakeMl: Int
    let goalMl: Int
    let lastUpdated: Date

    /// Fill fraction (0.0–1.0).
    var progress: Double {
        guard goalMl > 0 else { return 0 }
        return min(1.0, Double(intakeMl) / Double(goalMl))
    }

    var percentageText: String {
        "\(Int(progress * 100))%"
    }

    static let placeholder = WidgetWaterData(
        intakeMl: 1200,
        goalMl: 2000,
        lastUpdated: Date()
    )
}

// MARK: - WidgetDataProvider

/// Reads widget data from the shared App Group UserDefaults.
///
/// The main app is responsible for writing these keys whenever its data
/// changes. Call `WidgetCenter.shared.reloadAllTimelines()` from the main
/// app after writing to trigger an immediate widget update.
struct WidgetDataProvider {

    // MARK: App Group Suite

    private static let suiteName = "group.com.bloomher.shared"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    // MARK: - Cycle Data

    static func fetchCycleData() -> WidgetCycleData {
        guard let ud = defaults else {
            return .placeholder
        }

        let cycleDay    = ud.integer(forKey: "widget.cycleDay")
        let cycleLength = ud.integer(forKey: "widget.cycleLength")
        let phaseRaw    = ud.string(forKey: "widget.phase") ?? ""
        let phase       = WidgetCyclePhase(rawValue: phaseRaw) ?? .follicular

        let daysUntilNextPeriod: Int? = ud.object(forKey: "widget.daysUntilNextPeriod") != nil
            ? ud.integer(forKey: "widget.daysUntilNextPeriod")
            : nil

        let lastUpdatedInterval = ud.double(forKey: "widget.cycleLastUpdated")
        let lastUpdated: Date = lastUpdatedInterval > 0
            ? Date(timeIntervalSinceReferenceDate: lastUpdatedInterval)
            : Date()

        // Guard against uninitialised defaults (all zeroes).
        guard cycleDay > 0 else {
            return .placeholder
        }

        return WidgetCycleData(
            cycleDay: cycleDay,
            cycleLength: max(21, min(45, cycleLength > 0 ? cycleLength : 28)),
            phase: phase,
            daysUntilNextPeriod: daysUntilNextPeriod,
            lastUpdated: lastUpdated
        )
    }

    // MARK: - Pregnancy Data

    static func fetchPregnancyData() -> WidgetPregnancyData {
        guard let ud = defaults else {
            return .placeholder
        }

        let week       = ud.integer(forKey: "widget.pregnancyWeek")
        let trimester  = ud.integer(forKey: "widget.trimester")
        let daysUntilDue = ud.integer(forKey: "widget.daysUntilDue")
        let babySize   = ud.string(forKey: "widget.babySize") ?? "Unknown"

        let lastUpdatedInterval = ud.double(forKey: "widget.pregnancyLastUpdated")
        let lastUpdated: Date = lastUpdatedInterval > 0
            ? Date(timeIntervalSinceReferenceDate: lastUpdatedInterval)
            : Date()

        guard week > 0 else {
            return .placeholder
        }

        return WidgetPregnancyData(
            currentWeek: max(1, min(42, week)),
            trimester: max(1, min(3, trimester > 0 ? trimester : 1)),
            daysUntilDue: max(0, daysUntilDue),
            babySize: babySize,
            lastUpdated: lastUpdated
        )
    }

    // MARK: - Water Data

    static func fetchWaterData() -> WidgetWaterData {
        guard let ud = defaults else {
            return .placeholder
        }

        let intakeMl = ud.integer(forKey: "widget.waterIntakeMl")
        let goalMl   = ud.integer(forKey: "widget.waterGoalMl")

        let lastUpdatedInterval = ud.double(forKey: "widget.waterLastUpdated")
        let lastUpdated: Date = lastUpdatedInterval > 0
            ? Date(timeIntervalSinceReferenceDate: lastUpdatedInterval)
            : Date()

        return WidgetWaterData(
            intakeMl: max(0, intakeMl),
            goalMl: goalMl > 0 ? goalMl : 2000,
            lastUpdated: lastUpdated
        )
    }
}

// MARK: - UserDefaults Write Helpers (called from the main app target)
//
// The main app should import this file or replicate these key names.
// Provided here as documentation — the widget extension never writes these.
//
//  extension UserDefaults {
//      func writeWidgetCycleData(cycleDay: Int, cycleLength: Int,
//                                phase: String, daysUntilNextPeriod: Int?) {
//          let ud = UserDefaults(suiteName: "group.com.bloomher.shared")!
//          ud.set(cycleDay,    forKey: "widget.cycleDay")
//          ud.set(cycleLength, forKey: "widget.cycleLength")
//          ud.set(phase,       forKey: "widget.phase")
//          if let days = daysUntilNextPeriod {
//              ud.set(days,    forKey: "widget.daysUntilNextPeriod")
//          } else {
//              ud.removeObject(forKey: "widget.daysUntilNextPeriod")
//          }
//          ud.set(Date().timeIntervalSinceReferenceDate, forKey: "widget.cycleLastUpdated")
//          WidgetCenter.shared.reloadTimelines(ofKind: "CycleDayWidget")
//      }
//  }
