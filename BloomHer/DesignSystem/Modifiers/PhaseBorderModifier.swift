//
//  PhaseBorderModifier.swift
//  BloomHer
//
//  A ViewModifier that adds a RoundedRectangle stroke in the current cycle
//  phase's color. The phase is read from the environment so no manual
//  propagation is needed.
//
//  Apply via the `.phaseBorder(lineWidth:)` convenience extension on `View`
//  (defined in Utilities/ViewExtensions.swift).
//

import SwiftUI

// MARK: - PhaseBorderModifier

/// Overlays a rounded-rectangle stroke whose color tracks the active cycle phase.
///
/// Because this modifier reads `\.currentCyclePhase` from the SwiftUI
/// environment, it updates automatically whenever the root view injects a
/// new phase value — no extra wiring is required at the call site.
///
/// ```swift
/// Image(systemName: "heart.fill")
///     .padding()
///     .phaseBorder(lineWidth: 2)
/// ```
public struct PhaseBorderModifier: ViewModifier {

    // MARK: Configuration

    /// The stroke width of the phase-colored border.
    public let lineWidth: CGFloat

    /// The corner radius of the rounded rectangle stroke.
    public let cornerRadius: CGFloat

    // MARK: Environment

    @Environment(\.currentCyclePhase) private var cyclePhase

    // MARK: Init

    public init(lineWidth: CGFloat = 2, cornerRadius: CGFloat = BloomHerTheme.Radius.medium) {
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
    }

    // MARK: Body

    public func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(BloomHerTheme.Colors.phase(cyclePhase), lineWidth: lineWidth)
            }
    }
}

// MARK: - Preview

#Preview("Phase Border Modifier") {
    VStack(spacing: BloomHerTheme.Spacing.lg) {
        ForEach(CyclePhase.allCases, id: \.self) { phase in
            Text(phase.displayName)
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(BloomHerTheme.Spacing.md)
                .modifier(PhaseBorderModifier(lineWidth: 2))
                .environment(\.currentCyclePhase, phase)
        }
    }
    .padding(BloomHerTheme.Spacing.md)
    .background(BloomHerTheme.Colors.background)
}
