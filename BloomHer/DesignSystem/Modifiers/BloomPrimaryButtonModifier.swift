//
//  BloomPrimaryButtonModifier.swift
//  BloomHer
//
//  A ViewModifier that applies the BloomHer primary-button appearance to
//  any view label: full-width, pill-shaped, rose-peach gradient background
//  with white headline text. Disabled state uses a gray gradient and
//  a slight scale-down to signal inactivity.
//
//  Apply via the `.bloomPrimaryButton(enabled:)` convenience extension
//  on `View` (defined in Utilities/ViewExtensions.swift).
//

import SwiftUI

// MARK: - BloomPrimaryButtonModifier

/// Styles a view label as the BloomHer primary action button.
///
/// Intended for use inside a `Button` that already carries a `ScaleButtonStyle`:
/// ```swift
/// Button("Save") { save() }
///     .buttonStyle(ScaleButtonStyle())
///     .bloomPrimaryButton(enabled: isFormValid)
/// ```
public struct BloomPrimaryButtonModifier: ViewModifier {

    // MARK: Configuration

    /// Whether the button is interactive. Pass `false` to show the disabled state.
    public let enabled: Bool

    // MARK: Body

    public func body(content: Content) -> some View {
        content
            .font(BloomHerTheme.Typography.headline)
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.pill, style: .continuous)
                    .fill(backgroundFill)
            )
            .scaleEffect(enabled ? 1.0 : 0.98)
            .animation(BloomHerTheme.Animation.quick, value: enabled)
            .allowsHitTesting(enabled)
    }

    // MARK: Private

    private var backgroundFill: AnyShapeStyle {
        if enabled {
            return AnyShapeStyle(BloomColors.primaryRose)
        } else {
            return AnyShapeStyle(Color(.systemGray4))
        }
    }
}

// MARK: - Preview

#Preview("Primary Button Modifier") {
    VStack(spacing: BloomHerTheme.Spacing.lg) {
        Text("Enabled")
            .modifier(BloomPrimaryButtonModifier(enabled: true))

        Text("Disabled")
            .modifier(BloomPrimaryButtonModifier(enabled: false))
    }
    .padding(BloomHerTheme.Spacing.md)
    .background(BloomHerTheme.Colors.background)
}
