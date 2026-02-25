//
//  BloomShadow.swift
//  BloomHer
//
//  A lightweight value type that bundles all parameters needed to apply a
//  SwiftUI shadow modifier. Using a struct instead of raw modifier call-sites
//  keeps shadow definitions centralised in `BloomHerTheme` and lets views
//  consume them with a single convenience modifier.
//

import SwiftUI

// MARK: - BloomShadow

/// Encapsulates a single SwiftUI drop-shadow definition.
///
/// All shadow tokens used in BloomHer are expressed as `BloomShadow` values
/// and vended through `BloomHerTheme.Shadows`. Applying them is done via the
/// `.bloomShadow(_:)` view modifier defined in this file.
public struct BloomShadow {

    // MARK: Properties

    /// The shadow fill color (including any opacity already embedded in the color).
    public let color: Color

    /// Gaussian blur radius of the shadow.
    public let radius: CGFloat

    /// Horizontal offset (positive values push the shadow right).
    public let x: CGFloat

    /// Vertical offset (positive values push the shadow down).
    public let y: CGFloat

    // MARK: Init

    /// Creates a `BloomShadow` with the supplied parameters.
    ///
    /// - Parameters:
    ///   - color:  Shadow color.
    ///   - radius: Blur radius in points.
    ///   - x:      Horizontal offset in points.
    ///   - y:      Vertical offset in points.
    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color  = color
        self.radius = radius
        self.x      = x
        self.y      = y
    }
}

// MARK: - View Modifier Convenience

extension View {

    /// Applies a `BloomShadow` token as a SwiftUI shadow modifier.
    ///
    /// ```swift
    /// MyCard()
    ///     .bloomShadow(BloomHerTheme.Shadows.medium)
    /// ```
    ///
    /// - Parameter shadow: The `BloomShadow` token to apply.
    /// - Returns: A view with the shadow applied.
    @inlinable
    public func bloomShadow(_ shadow: BloomShadow) -> some View {
        self.shadow(
            color:  shadow.color,
            radius: shadow.radius,
            x:      shadow.x,
            y:      shadow.y
        )
    }
}
