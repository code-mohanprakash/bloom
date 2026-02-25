//
//  ViewExtensions.swift
//  BloomHer
//
//  Convenience `View` extension methods that wrap the BloomHer design-system
//  modifiers in a fluent, chainable API. Import this file once and every view
//  in the module gains access to the full modifier suite.
//
//  All modifiers delegate to their matching `ViewModifier` struct defined in
//  `DesignSystem/Modifiers/`. The `CardElevation` enum lives here because it
//  is a configuration value consumed at the call site.
//

import SwiftUI

// MARK: - View + BloomHer Modifiers

public extension View {

    // MARK: Card

    /// Wraps the view in the standard BloomHer card chrome.
    ///
    /// - Parameters:
    ///   - phaseAware: When `true`, a 3 pt phase-colored leading accent bar is
    ///     overlaid on the card. Defaults to `false`.
    ///   - elevation: Controls drop-shadow depth in light mode. In dark mode a
    ///     1 pt white border replaces the shadow. Defaults to `.medium`.
    func bloomCard(
        phaseAware: Bool = false,
        elevation: CardElevation = .medium,
        tonal: Bool = false
    ) -> some View {
        modifier(BloomCardModifier(phaseAware: phaseAware, elevation: elevation, tonal: tonal))
    }

    // MARK: Primary Button

    /// Styles the view as the BloomHer primary action button label.
    ///
    /// Apply this to the label content of a `Button` that already carries
    /// a `ScaleButtonStyle`. Pair with `.disabled(_:)` on the `Button` itself
    /// if you also want to block interaction.
    ///
    /// - Parameter enabled: When `false`, the gradient is replaced with gray
    ///   and the label scales to 0.98. Defaults to `true`.
    func bloomPrimaryButton(enabled: Bool = true) -> some View {
        modifier(BloomPrimaryButtonModifier(enabled: enabled))
    }

    // MARK: Navigation

    /// Configures themed navigation-bar styling and sets the navigation title.
    ///
    /// - Parameter title: The string displayed in the navigation bar.
    func bloomNavigation(_ title: String) -> some View {
        modifier(BloomNavigationModifier(title: title))
    }

    // MARK: Phase Border

    /// Overlays a rounded-rectangle stroke whose color tracks the active cycle phase.
    ///
    /// - Parameters:
    ///   - lineWidth: The width of the stroke. Defaults to `2`.
    ///   - cornerRadius: The corner radius of the stroke shape. Defaults to
    ///     `BloomHerTheme.Radius.medium`.
    func phaseBorder(
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = BloomHerTheme.Radius.medium
    ) -> some View {
        modifier(PhaseBorderModifier(lineWidth: lineWidth, cornerRadius: cornerRadius))
    }

    // MARK: Scroll Background

    /// Applies the BloomHer scroll-background treatment to a `ScrollView` or `List`.
    ///
    /// Hides the system scroll content background, sets the app's adaptive
    /// background color, and tints interactive elements with `primaryRose`.
    func bloomBackground() -> some View {
        modifier(BloomScrollModifier())
    }

    // MARK: Shimmer

    /// Overlays a continuously sweeping shimmer highlight to indicate a loading state.
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }

    // MARK: Staggered Appear

    /// Animates the view's entrance with a staggered slide-up and fade effect.
    ///
    /// - Parameter index: The item's position in its container. Each increment
    ///   adds 50 ms of delay before the entrance animation starts.
    func staggeredAppear(index: Int) -> some View {
        modifier(StaggeredAppearModifier(index: index))
    }

    // MARK: Sheet Presentation

    /// Applies standard BloomHer sheet presentation styling.
    ///
    /// Configures detents, a rounded corner radius, and a visible drag indicator
    /// for a consistent, polished sheet appearance throughout the app.
    ///
    /// - Parameter detents: The allowed sheet heights. Defaults to medium and large.
    func bloomSheet(
        detents: Set<PresentationDetent> = [.medium, .large]
    ) -> some View {
        self
            .presentationDetents(detents)
            .presentationCornerRadius(BloomHerTheme.Radius.xl)
            .presentationDragIndicator(.visible)
    }
}
