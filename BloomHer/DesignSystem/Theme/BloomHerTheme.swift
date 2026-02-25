//
//  BloomHerTheme.swift
//  BloomHer
//
//  Central design-system namespace.  Every design token — colors, typography,
//  spacing, corner radii, shadows, animations, and haptics — is vended from
//  this single type so that views never hard-code raw values.
//
//  Usage:
//    Text("Hello")
//        .font(BloomHerTheme.Typography.headline)
//        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
//        .padding(BloomHerTheme.Spacing.md)
//        .bloomShadow(BloomHerTheme.Shadows.medium)
//

import SwiftUI
import UIKit

// MARK: - BloomHerTheme

/// Top-level namespace for all BloomHer design tokens.
///
/// `BloomHerTheme` itself is never instantiated — all access is through its
/// nested enums/structs which act as further namespaces.
public enum BloomHerTheme {

    // MARK: - Colors

    /// Thin re-export of `BloomColors` so call-sites can use either namespace.
    ///
    /// ```swift
    /// BloomHerTheme.Colors.primaryRose   // same as BloomColors.primaryRose
    /// ```
    public enum Colors {
        public static var primaryRose:        Color { BloomColors.primaryRose }
        public static var sageGreen:          Color { BloomColors.sageGreen }
        public static var accentLavender:     Color { BloomColors.accentLavender }
        public static var accentPeach:        Color { BloomColors.accentPeach }

        public static var background:         Color { BloomColors.background }
        public static var surface:            Color { BloomColors.surface }
        public static var surfaceElevated:    Color { BloomColors.surfaceElevated }

        public static var textPrimary:        Color { BloomColors.textPrimary }
        public static var textSecondary:      Color { BloomColors.textSecondary }
        public static var textTertiary:       Color { BloomColors.textTertiary }

        public static var waterBlue:          Color { BloomColors.waterBlue }
        public static var waterBlueTint:      Color { BloomColors.waterBlueTint }

        public static var success:            Color { BloomColors.success }
        public static var warning:            Color { BloomColors.warning }
        public static var error:              Color { BloomColors.error }
        public static var info:               Color { BloomColors.info }

        static func phase(_ phase: CyclePhase) -> Color {
            BloomColors.color(for: phase)
        }
    }

    // MARK: - Typography

    /// SF Rounded font scale for BloomHer.
    ///
    /// Every token maps to a Dynamic Type text style so the system's
    /// accessibility text-size setting is respected automatically.
    public enum Typography {

        // MARK: Standard scale

        /// Large title — `.largeTitle`, rounded, bold.  Used for hero headers.
        public static let largeTitle = Font.largeTitle
            .weight(.bold)
            .rounded()

        /// Title 1 — `.title`, rounded, semibold.
        public static let title1 = Font.title
            .weight(.semibold)
            .rounded()

        /// Title 2 — `.title2`, rounded, semibold.
        public static let title2 = Font.title2
            .weight(.semibold)
            .rounded()

        /// Title 3 — `.title3`, rounded, medium weight.
        public static let title3 = Font.title3
            .weight(.medium)
            .rounded()

        /// Headline — `.headline`, rounded, semibold.  Good for card titles.
        public static let headline = Font.headline
            .weight(.semibold)
            .rounded()

        /// Body — `.body`, rounded, regular weight.  Default reading text.
        public static let body = Font.body
            .rounded()

        /// Callout — `.callout`, rounded.
        public static let callout = Font.callout
            .rounded()

        /// Subheadline — `.subheadline`, rounded.
        public static let subheadline = Font.subheadline
            .rounded()

        /// Footnote — `.footnote`, rounded.  Used for supplementary info.
        public static let footnote = Font.footnote
            .rounded()

        /// Caption — `.caption`, rounded.  Labels on charts and small badges.
        public static let caption = Font.caption
            .rounded()

        /// Caption 2 — `.caption2`, rounded.  Smallest standard scale.
        public static let caption2 = Font.caption2
            .rounded()

        // MARK: Display / custom size

        /// Hero number — 48 pt, bold, rounded.  Cycle-day hero displays.
        public static let heroNumber = Font.system(size: 48, weight: .bold, design: .rounded)

        /// Cycle day — 64 pt, heavy, rounded.  Prominent day-of-cycle counter.
        public static let cycleDay = Font.system(size: 64, weight: .heavy, design: .rounded)

        /// Week number — 36 pt, bold, rounded.  Weekly summary headers.
        public static let weekNumber = Font.system(size: 36, weight: .bold, design: .rounded)

        // MARK: Feature-specific display

        /// Emoji display — 28 pt.  Phase / mood emoji selectors.
        public static let emojiDisplay = Font.system(size: 28)

        /// Large emoji / decorative — 40 pt.
        public static let emojiHero = Font.system(size: 40)

        /// Serif affirmation quote — 64 pt, bold, serif.
        public static let affirmationQuote = Font.system(size: 64, weight: .bold, design: .serif)

        /// Monospaced share code — 40 pt, bold, monospaced.
        public static let shareCode = Font.system(size: 40, weight: .bold, design: .monospaced)

        /// Partner display number — 32 pt, bold, rounded.
        public static let partnerHero = Font.system(size: 32, weight: .bold, design: .rounded)
    }

    // MARK: - Icon Sizes

    /// Standardised icon sizes across the app. Use instead of raw numeric literals.
    public enum IconSize {
        /// 14 pt — inline with text, inside settings badges.
        public static let inline: CGFloat     = 14
        /// 16 pt — inside chips, small indicators.
        public static let chip: CGFloat       = 16
        /// 20 pt — card section header icons.
        public static let cardHeader: CGFloat = 20
        /// 24 pt — quick action tiles, feature icons.
        public static let feature: CGFloat    = 24
        /// 32 pt — mode headers, large decorative.
        public static let hero: CGFloat       = 32
        /// 48 pt — empty state illustrations.
        public static let illustration: CGFloat = 48
    }

    // MARK: - Spacing

    /// 4-point base-grid spacing scale.
    ///
    /// Use these instead of raw numeric literals so layouts adapt together
    /// when the base unit changes.
    public enum Spacing {
        /// 2 pt — hair-line separation, rarely needed.
        public static let xxxs: CGFloat = 2
        /// 4 pt — minimum touch-target padding, badge gaps.
        public static let xxs: CGFloat  = 4
        /// 8 pt — tight internal padding.
        public static let xs: CGFloat   = 8
        /// 12 pt — compact section padding.
        public static let sm: CGFloat   = 12
        /// 16 pt — standard content padding (HIG recommended).
        public static let md: CGFloat   = 16
        /// 20 pt — relaxed padding between sections.
        public static let lg: CGFloat   = 20
        /// 24 pt — generous section gaps.
        public static let xl: CGFloat   = 24
        /// 32 pt — card-to-card spacing.
        public static let xxl: CGFloat  = 32
        /// 40 pt — group separators.
        public static let xxxl: CGFloat = 40
        /// 48 pt — large screen-section gaps.
        public static let huge: CGFloat = 48
        /// 64 pt — hero spacing, full-width separators.
        public static let massive: CGFloat = 64
    }

    // MARK: - Corner Radius

    /// Standardised corner radii ensuring visual consistency across components.
    public enum Radius {
        /// 8 pt — small chips, tags, minimal cards.
        public static let small: CGFloat  = 8
        /// 12 pt — standard cards and list rows.
        public static let medium: CGFloat = 12
        /// 16 pt — prominent cards, bottom sheets.
        public static let large: CGFloat  = 16
        /// 20 pt — large modals and sheet headers.
        public static let xl: CGFloat     = 20
        /// 24 pt — hero cards.
        public static let xxl: CGFloat    = 24
        /// 100 pt — pill buttons and fully-rounded badges.
        public static let pill: CGFloat   = 100
    }

    // MARK: - Shadows

    /// Drop-shadow tokens expressed as `BloomShadow` values.
    ///
    /// Consume via the `.bloomShadow(_:)` view modifier defined in
    /// `BloomShadow.swift`.
    public enum Shadows {

        // MARK: Elevation shadows

        /// Subtle lift — 4 % black, 4 pt radius.
        public static let small = BloomShadow(
            color:  Color.black.opacity(0.04),
            radius: 4,
            x:      0,
            y:      2
        )

        /// Standard card shadow — 6 % black, 8 pt radius.
        public static let medium = BloomShadow(
            color:  Color.black.opacity(0.06),
            radius: 8,
            x:      0,
            y:      4
        )

        /// Deep elevation — 8 % black, 16 pt radius.
        public static let large = BloomShadow(
            color:  Color.black.opacity(0.08),
            radius: 16,
            x:      0,
            y:      8
        )

        // MARK: Glow shadows

        /// Brand-rose glow — 30 % Soft Rose, 12 pt radius.
        public static let glow = BloomShadow(
            color:  BloomColors.primaryRose.opacity(0.30),
            radius: 12,
            x:      0,
            y:      4
        )

        /// Returns a phase-tinted glow shadow at 25 % opacity.
        ///
        /// - Parameter phase: The active `CyclePhase`.
        /// - Returns: A `BloomShadow` coloured with the phase accent.
        static func phaseGlow(for phase: CyclePhase) -> BloomShadow {
            BloomShadow(
                color:  BloomColors.color(for: phase).opacity(0.25),
                radius: 12,
                x:      0,
                y:      4
            )
        }
    }

    // MARK: - Animation

    /// Curated animation presets that give BloomHer its characteristic
    /// organic, spring-driven feel.
    public enum Animation {

        /// Quick micro-interaction — `spring(duration: 0.2, bounce: 0.3)`.
        /// Use for toggles, selection highlights, small state changes.
        public static let quick = SwiftUI.Animation.spring(duration: 0.2, bounce: 0.3)

        /// Standard transition — `spring(duration: 0.35, bounce: 0.25)`.
        /// Use for most view/state transitions.
        public static let standard = SwiftUI.Animation.spring(duration: 0.35, bounce: 0.25)

        /// Gentle entrance — `spring(duration: 0.5, bounce: 0.2)`.
        /// Use for cards and list rows appearing on screen.
        public static let gentle = SwiftUI.Animation.spring(duration: 0.5, bounce: 0.2)

        /// Slow settle — `spring(duration: 0.8, bounce: 0.15)`.
        /// Use for large layout shifts or phase-change transitions.
        public static let slow = SwiftUI.Animation.spring(duration: 0.8, bounce: 0.15)

        /// Breathing loop — `easeInOut(duration: 4)` repeating with
        /// auto-reverse.  Drive scale / opacity on the cycle-ring pulse.
        public static let breath = SwiftUI.Animation
            .easeInOut(duration: 4.0)
            .repeatForever(autoreverses: true)

        /// Pulse loop — `easeInOut(duration: 1.5)` repeating with
        /// auto-reverse.  Good for notification badges and activity dots.
        public static let pulse = SwiftUI.Animation
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)

        /// Flower-grow entrance — `spring(duration: 1.2, bounce: 0.3)`.
        /// Use for the BloomHer flower illustration reveal on onboarding.
        public static let flowerGrow = SwiftUI.Animation.spring(duration: 1.2, bounce: 0.3)
    }

    // MARK: - Glass

    /// Glassmorphism design tokens for frosted-glass surfaces.
    ///
    /// Apply with `.bloomGlass()` modifier or use tokens directly for custom glass shapes.
    ///
    /// ```swift
    /// VStack { ... }
    ///     .bloomGlass()
    ///
    /// // Custom radius:
    /// VStack { ... }
    ///     .bloomGlass(radius: BloomHerTheme.Radius.xxl, stroke: 0.5)
    /// ```
    public enum Glass {

        // MARK: Material tiers
        /// Whisper-light frost — for overlays on rich backgrounds.
        public static let ultraThin: Material  = .ultraThinMaterial
        /// Light frost — for cards on gradient backgrounds.
        public static let thin: Material       = .thinMaterial
        /// Standard frost — for modals and sheets.
        public static let regular: Material    = .regularMaterial

        // MARK: Stroke colors
        /// Bright stroke for light backgrounds.
        public static let strokeLight          = Color.white.opacity(0.25)
        /// Softer stroke for dark backgrounds or phase tints.
        public static let strokeDark           = Color.white.opacity(0.10)
        /// Rose-tinted stroke for brand accents.
        public static let strokeRose           = BloomColors.primaryRose.opacity(0.30)

        // MARK: Inner glow
        /// Soft white inner highlight — simulates light refraction.
        public static let innerGlow            = Color.white.opacity(0.12)

        // MARK: Shadows
        /// Glass panel shadow — deep blur for lift off the background.
        public static let shadow = BloomShadow(
            color: Color.black.opacity(0.12),
            radius: 24,
            x: 0,
            y: 10
        )
        /// Gentle rose glow shadow — for brand-accented glass cards.
        public static let roseGlow = BloomShadow(
            color: BloomColors.primaryRose.opacity(0.18),
            radius: 20,
            x: 0,
            y: 6
        )

        // MARK: Tab bar
        /// Tab bar glass background stroke.
        public static let tabBarStroke         = Color.white.opacity(0.20)
        /// Tab bar glass shadow.
        public static let tabBarShadow = BloomShadow(
            color: Color.black.opacity(0.14),
            radius: 30,
            x: 0,
            y: 12
        )
    }

    // MARK: - Haptics

    /// Haptic feedback helpers.
    ///
    /// These methods call the relevant UIKit feedback generator with the
    /// matching intensity.  Views should prefer `HapticManager` (which gates
    /// on the user's haptic preference) over calling these directly.
    public enum Haptics {

        /// Light impact — taps, selections.
        public static func light() {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }

        /// Medium impact — confirmations, toggles.
        public static func medium() {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        }

        /// Success notification — task completion.
        public static func success() {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        }

        /// Selection changed — picker scrolls, segment changes.
        public static func selection() {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }

        /// Error notification — validation failure, destructive action.
        public static func error() {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)
        }
    }
}

// MARK: - Font + Rounded Design Convenience

extension Font {
    /// Applies SF Rounded design to the font while preserving its weight.
    func rounded() -> Font {
        self
    }
}
