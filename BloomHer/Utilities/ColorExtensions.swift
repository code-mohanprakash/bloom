//
//  ColorExtensions.swift
//  BloomHer
//
//  Foundational Color extensions for hex parsing and adaptive light/dark mode support.
//

import SwiftUI
import UIKit

extension Color {

    // MARK: - Hex Initializer

    /// Creates a `Color` from a hex string.
    ///
    /// Accepts formats with or without a leading `#`, and supports:
    /// - 6-character RGB: `"F4A0B5"` or `"#F4A0B5"`
    /// - 8-character RGBA: `"F4A0B5FF"` or `"#F4A0B5FF"`
    ///
    /// - Parameter hex: The hex color string to parse.
    init(hex: String) {
        let normalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))

        var rgbaValue: UInt64 = 0
        Scanner(string: normalized).scanHexInt64(&rgbaValue)

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        switch normalized.count {
        case 6:
            red   = Double((rgbaValue & 0xFF0000) >> 16) / 255.0
            green = Double((rgbaValue & 0x00FF00) >> 8)  / 255.0
            blue  = Double( rgbaValue & 0x0000FF)        / 255.0
            alpha = 1.0
        case 8:
            red   = Double((rgbaValue & 0xFF000000) >> 24) / 255.0
            green = Double((rgbaValue & 0x00FF0000) >> 16) / 255.0
            blue  = Double((rgbaValue & 0x0000FF00) >> 8)  / 255.0
            alpha = Double( rgbaValue & 0x000000FF)        / 255.0
        default:
            // Fallback to clear on invalid input — prevents silent failures in production
            red   = 0
            green = 0
            blue  = 0
            alpha = 0
        }

        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }

    // MARK: - Adaptive Light / Dark Initializer

    /// Creates an adaptive `Color` that responds to the current color scheme.
    ///
    /// Uses `UIColor(dynamicProvider:)` under the hood so the color updates
    /// automatically when the user switches between light and dark mode, including
    /// during live trait-collection changes (split-screen, Stage Manager, etc.).
    ///
    /// - Parameters:
    ///   - light: The color used in light mode (`.light` user interface style).
    ///   - dark:  The color used in dark mode (`.dark` user interface style).
    init(light: Color, dark: Color) {
        let uiColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        }
        self.init(uiColor: uiColor)
    }
}
