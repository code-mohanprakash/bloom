//
//  ScaleButtonStyle.swift
//  BloomHer
//
//  A ButtonStyle that applies a spring-driven scale effect on press.
//  The pressed state shrinks the button to 96% of its natural size using
//  BloomHerTheme.Animation.quick so the interaction feels snappy and physical.
//

import SwiftUI

// MARK: - ScaleButtonStyle

/// A custom `ButtonStyle` that scales the label down slightly on press.
///
/// Use this style as the foundation for all interactive tap targets in BloomHer
/// that need tactile scale feedback without additional visual decoration.
///
/// ```swift
/// Button("Tap me") { }
///     .buttonStyle(ScaleButtonStyle())
/// ```
public struct ScaleButtonStyle: ButtonStyle {

    // MARK: ButtonStyle

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(BloomHerTheme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - ButtonStyle Convenience

public extension ButtonStyle where Self == ScaleButtonStyle {
    /// The BloomHer scale button style.
    static var scale: ScaleButtonStyle { ScaleButtonStyle() }
}

// MARK: - Preview

#Preview("Scale Button Style") {
    VStack(spacing: BloomHerTheme.Spacing.lg) {
        Button("Press and Hold Me") { }
            .buttonStyle(ScaleButtonStyle())
            .padding(BloomHerTheme.Spacing.md)
            .background(BloomHerTheme.Colors.primaryRose, in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium))
            .foregroundStyle(.white)
            .font(BloomHerTheme.Typography.headline)

        Button("Another Button") { }
            .buttonStyle(.scale)
            .padding(BloomHerTheme.Spacing.md)
            .background(BloomHerTheme.Colors.sageGreen, in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium))
            .foregroundStyle(.white)
            .font(BloomHerTheme.Typography.headline)
    }
    .padding()
}
