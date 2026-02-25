//
//  BloomScrollModifier.swift
//  BloomHer
//
//  A ViewModifier that configures a ScrollView (or List) with the correct
//  BloomHer background and tint. Hides the default scroll content background
//  so the view's own background shows through, and tints pull-to-refresh
//  indicators with the brand rose color.
//
//  Apply via the `.bloomBackground()` convenience extension on `View`
//  (defined in Utilities/ViewExtensions.swift).
//

import SwiftUI

// MARK: - BloomScrollModifier

/// Applies the BloomHer scroll background treatment to a `ScrollView` or `List`.
///
/// - Hides the system's scroll content background (required for custom List backgrounds).
/// - Sets the view background to `BloomHerTheme.Colors.background`, which is
///   adaptive: warm cream in light mode, deep plum in dark mode.
/// - Tints the view (including pull-to-refresh spinners) with `primaryRose`.
///
/// ```swift
/// List(items) { item in
///     ItemRow(item: item)
/// }
/// .bloomBackground()
/// ```
public struct BloomScrollModifier: ViewModifier {

    // MARK: Body

    public func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(BloomHerTheme.Colors.background)
            .tint(BloomHerTheme.Colors.primaryRose)
    }
}

// MARK: - Preview

#Preview("Bloom Background Modifier") {
    List(0..<12, id: \.self) { index in
        Text("Row \(index + 1)")
            .font(BloomHerTheme.Typography.body)
            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            .listRowBackground(BloomHerTheme.Colors.surface)
    }
    .modifier(BloomScrollModifier())
}
