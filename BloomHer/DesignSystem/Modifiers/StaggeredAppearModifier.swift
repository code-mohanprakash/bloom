//
//  StaggeredAppearModifier.swift
//  BloomHer
//
//  A ViewModifier that produces a staggered entrance animation: each
//  item slides up from a 20pt offset while fading in, with a delay
//  proportional to its position index in a list.
//
//  Apply via the `.staggeredAppear(index:)` convenience extension on `View`
//  (defined in Utilities/ViewExtensions.swift).
//

import SwiftUI

// MARK: - StaggeredAppearModifier

/// Animates a view's entrance with a slide-up + fade effect, delayed by
/// `index * 0.05` seconds to create a cascading list reveal.
///
/// ```swift
/// ForEach(Array(items.enumerated()), id: \.offset) { index, item in
///     ItemRow(item)
///         .staggeredAppear(index: index)
/// }
/// ```
///
/// - The view starts at `opacity: 0` and `offset y: 20`.
/// - On appear it transitions to `opacity: 1` and `offset y: 0` using
///   `BloomHerTheme.Animation.standard` with an index-based delay.
public struct StaggeredAppearModifier: ViewModifier {

    // MARK: Configuration

    /// The item's position in its container. Larger values produce longer delays.
    public let index: Int

    // MARK: State

    @State private var hasAppeared: Bool = false

    // MARK: Body

    public func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 20)
            .onAppear {
                let delay = Double(index) * 0.05
                withAnimation(BloomHerTheme.Animation.standard.delay(delay)) {
                    hasAppeared = true
                }
            }
    }
}

// MARK: - Preview

#Preview("Staggered Appear Modifier") {
    ScrollView {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            ForEach(0..<10) { index in
                HStack {
                    Text("Item \(index + 1)")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    Image(BloomIcons.chevronRight)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }
                .padding(BloomHerTheme.Spacing.md)
                .background(BloomHerTheme.Colors.surface, in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium))
                .staggeredAppear(index: index)
            }
        }
        .padding(BloomHerTheme.Spacing.md)
    }
    .background(BloomHerTheme.Colors.background)
}
