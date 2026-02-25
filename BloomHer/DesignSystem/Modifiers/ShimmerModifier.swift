//
//  ShimmerModifier.swift
//  BloomHer
//
//  A ViewModifier that overlays a continuously sliding diagonal gradient
//  to indicate a loading/skeleton state. The gradient slides from leading
//  to trailing and repeats indefinitely.
//
//  Apply via the `.shimmer()` convenience extension on `View`
//  (defined in Utilities/ViewExtensions.swift).
//

import SwiftUI

// MARK: - ShimmerModifier

/// Overlays a sweeping highlight gradient on top of the content to indicate
/// a loading or skeleton state.
///
/// The effect uses a `LinearGradient` that transitions from clear through
/// white at 30% opacity and back to clear, swept diagonally. A `@State`
/// variable animates the X offset from -1 to 1 in a repeating linear
/// animation so the highlight continuously moves across the view.
///
/// ```swift
/// RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium)
///     .fill(Color(.systemGray5))
///     .frame(height: 60)
///     .shimmer()
/// ```
public struct ShimmerModifier: ViewModifier {

    // MARK: State

    @State private var phase: CGFloat = -1

    // MARK: Body

    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    shimmerGradient
                        .frame(width: geometry.size.width * 3)
                        .offset(x: phase * geometry.size.width * 2)
                }
                .clipped()
                .allowsHitTesting(false)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.4)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }

    // MARK: Private

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .clear,                  location: 0.0),
                .init(color: .clear,                  location: 0.3),
                .init(color: .white.opacity(0.30),    location: 0.5),
                .init(color: .clear,                  location: 0.7),
                .init(color: .clear,                  location: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Preview

#Preview("Shimmer Modifier") {
    VStack(spacing: BloomHerTheme.Spacing.md) {
        // Simulate skeleton rows
        ForEach(0..<4) { _ in
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 44, height: 44)
                    .shimmer()

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small)
                        .fill(Color(.systemGray5))
                        .frame(height: 14)
                        .shimmer()

                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small)
                        .fill(Color(.systemGray5))
                        .frame(width: 120, height: 12)
                        .shimmer()
                }
            }
            .padding(BloomHerTheme.Spacing.md)
            .background(BloomHerTheme.Colors.surface, in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium))
        }
    }
    .padding(BloomHerTheme.Spacing.md)
    .background(BloomHerTheme.Colors.background)
}
