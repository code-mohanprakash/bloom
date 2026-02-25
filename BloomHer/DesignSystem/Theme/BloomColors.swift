//
//  BloomColors.swift
//  BloomHer
//
//  Central color palette for the Soft Rose & Blush design language.
//  All colors are adaptive and respond automatically to light / dark mode.
//
//  Palette pillars:
//    - Primary:   Soft Rose   #F4A0B5
//    - Secondary: Sage Green  #A8D5BA
//    - Accents:   Lavender    #C7B8EA  |  Peach  #F9D5A7
//    - Dark bg:   Deep Plum   #1E1520
//

import SwiftUI

// MARK: - Forward declaration dependency
// CyclePhase is defined in Models/Enums/CyclePhase.swift:
// enum CyclePhase: String, Codable, CaseIterable { case menstrual, follicular, ovulation, luteal }

// MARK: - BloomColors

/// Namespace for every color token used in the BloomHer design system.
///
/// Always consume colors through this type rather than hard-coding hex values
/// in views. This guarantees a single source of truth and makes palette
/// updates trivial.
public enum BloomColors {

    // MARK: - Brand / Primary

    /// Soft Rose – the primary brand color.
    public static let primaryRose = Color(hex: "#F4A0B5")

    /// Sage Green – secondary brand color, used for success states and the
    /// follicular phase.
    public static let sageGreen = Color(hex: "#A8D5BA")

    /// Accent Lavender – used for subtle highlights and the luteal phase.
    public static let accentLavender = Color(hex: "#C7B8EA")

    /// Accent Peach – warm accent used for warnings and the ovulation phase.
    public static let accentPeach = Color(hex: "#F9D5A7")

    // MARK: - Adaptive Background

    /// Main app background.
    ///
    /// Light: Warm Cream `#FFF8F5`  |  Dark: Deep Plum `#1E1520`
    public static let background = Color(
        light: Color(hex: "#FFF8F5"),
        dark:  Color(hex: "#1E1520")
    )

    /// Standard surface (cards, sheets).
    ///
    /// Light: `#FFFFFF`  |  Dark: `#2A1F2E`
    public static let surface = Color(
        light: Color(hex: "#FFFFFF"),
        dark:  Color(hex: "#2A1F2E")
    )

    /// Elevated surface (popovers, modals, floating elements).
    ///
    /// Light: `#FFFFFF`  |  Dark: `#362940`
    public static let surfaceElevated = Color(
        light: Color(hex: "#FFFFFF"),
        dark:  Color(hex: "#362940")
    )

    // MARK: - Adaptive Text

    /// Primary body text.
    ///
    /// Light: Warm Charcoal `#3D2C2E` at 100%  |  Dark: `#F5EEF0` at 100%
    public static let textPrimary = Color(
        light: Color(hex: "#3D2C2E"),
        dark:  Color(hex: "#F5EEF0")
    )

    /// Secondary text (labels, subtitles).
    ///
    /// Light: `#3D2C2E` @ 60 %  |  Dark: `#F5EEF0` @ 70 %
    public static let textSecondary = Color(
        light: Color(hex: "#3D2C2E").opacity(0.60),
        dark:  Color(hex: "#F5EEF0").opacity(0.70)
    )

    /// Tertiary text (placeholders, hints).
    ///
    /// Light: `#3D2C2E` @ 40 %  |  Dark: `#F5EEF0` @ 40 %
    public static let textTertiary = Color(
        light: Color(hex: "#3D2C2E").opacity(0.40),
        dark:  Color(hex: "#F5EEF0").opacity(0.40)
    )

    // MARK: - Adaptive Accents (dark mode uses 87 % opacity)

    /// Adaptive primary rose – full opacity in light, 87 % in dark.
    public static let adaptivePrimaryRose = Color(
        light: Color(hex: "#F4A0B5"),
        dark:  Color(hex: "#F4A0B5").opacity(0.87)
    )

    /// Adaptive sage green.
    public static let adaptiveSageGreen = Color(
        light: Color(hex: "#A8D5BA"),
        dark:  Color(hex: "#A8D5BA").opacity(0.87)
    )

    /// Adaptive accent lavender.
    public static let adaptiveAccentLavender = Color(
        light: Color(hex: "#C7B8EA"),
        dark:  Color(hex: "#C7B8EA").opacity(0.87)
    )

    /// Adaptive accent peach.
    public static let adaptiveAccentPeach = Color(
        light: Color(hex: "#F9D5A7"),
        dark:  Color(hex: "#F9D5A7").opacity(0.87)
    )

    // MARK: - Cycle Phase Colors

    /// Menstrual phase – warm pink.
    public static let menstrual = Color(hex: "#E88B9C")

    /// Follicular phase – sage green (same as secondary brand color).
    public static let follicular = Color(hex: "#A8D5BA")

    /// Ovulation phase – warm peach.
    public static let ovulation = Color(hex: "#F9D5A7")

    /// Luteal phase – soft blue-violet.
    public static let luteal = Color(hex: "#B8C9E8")

    /// Returns the canonical display color for the given cycle phase.
    public static func color(for phase: CyclePhase) -> Color {
        switch phase {
        case .menstrual:  return menstrual
        case .follicular: return follicular
        case .ovulation:  return ovulation
        case .luteal:     return luteal
        }
    }

    // MARK: - Semantic Colors

    /// Success state – mirrors sage green.
    public static let success = sageGreen

    /// Warning state – mirrors accent peach.
    public static let warning = accentPeach

    /// Error / destructive state – mirrors menstrual pink.
    public static let error = menstrual

    /// Informational state – mirrors luteal blue.
    public static let info = luteal

    // MARK: - Feature Accents

    /// Water / hydration accent — sky blue.
    public static let waterBlue = Color(hex: "#3AAFE8")

    /// Lighter water tint for gradients.
    public static let waterBlueTint = Color(hex: "#AEE4F8")

    // MARK: - Gradients

    /// Primary brand gradient: Soft Rose → Accent Peach.
    public static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryRose, accentPeach],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Sage gradient: Sage Green → lighter sage tint.
    public static var sageGradient: LinearGradient {
        LinearGradient(
            colors: [sageGreen, Color(hex: "#D4EDE0")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Lavender gradient: Accent Lavender → soft lavender tint.
    public static var lavenderGradient: LinearGradient {
        LinearGradient(
            colors: [accentLavender, Color(hex: "#E8E0F5")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Phase-tinted background gradient for dashboards and phase cards.
    ///
    /// Fades from 18 % phase color at the top to 4 % at the bottom,
    /// creating a clearly visible phase-aware ambient wash.
    ///
    /// - Parameter phase: The active `CyclePhase`.
    /// - Returns: A `LinearGradient` tinted with the phase accent color.
    public static func phaseBackground(for phase: CyclePhase) -> LinearGradient {
        let phaseColor = color(for: phase)
        return LinearGradient(
            colors: [
                phaseColor.opacity(0.18),
                phaseColor.opacity(0.04)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
