//
//  NumberFormatting.swift
//  BloomHer
//
//  Centralised numeric formatters for health and wellness values.
//
//  All formatters are vended as shared singletons via a private backing store
//  so that `NumberFormatter` allocation (which is non-trivial) happens once
//  per format type rather than on every render pass.
//
//  Usage:
//    HealthFormatter.weight(68.5)        // "68.5 kg"
//    HealthFormatter.temperature(36.7)   // "36.7 °C"
//    HealthFormatter.percentage(0.72)    // "72%"
//    HealthFormatter.water(ml: 750)      // "750 ml"
//

import Foundation

// MARK: - HealthFormatter

/// Produces locale-aware, consistently formatted strings for health metrics.
public enum HealthFormatter {

    // MARK: - Weight

    /// Returns a weight string with one decimal place and a "kg" unit suffix.
    ///
    /// ```swift
    /// HealthFormatter.weight(68.5)  // → "68.5 kg"
    /// HealthFormatter.weight(50.0)  // → "50.0 kg"
    /// ```
    ///
    /// - Parameter kilograms: Weight value in kilograms.
    /// - Returns: Formatted string, e.g. `"68.5 kg"`.
    public static func weight(_ kilograms: Double) -> String {
        "\(weightNumberFormatter.string(from: NSNumber(value: kilograms)) ?? "\(kilograms)") kg"
    }

    // MARK: - Temperature

    /// Returns a basal body temperature string with one decimal place and a
    /// "°C" unit suffix.
    ///
    /// ```swift
    /// HealthFormatter.temperature(36.7)  // → "36.7 °C"
    /// ```
    ///
    /// - Parameter celsius: Temperature value in degrees Celsius.
    /// - Returns: Formatted string, e.g. `"36.7 °C"`.
    public static func temperature(_ celsius: Double) -> String {
        "\(temperatureNumberFormatter.string(from: NSNumber(value: celsius)) ?? "\(celsius)") °C"
    }

    // MARK: - Percentage

    /// Returns an integer percentage string.
    ///
    /// The input is expected as a value in the range 0.0 – 1.0 (i.e. 0.72
    /// represents 72 %).  Values outside this range are clamped before
    /// formatting.
    ///
    /// ```swift
    /// HealthFormatter.percentage(0.72)   // → "72%"
    /// HealthFormatter.percentage(1.0)    // → "100%"
    /// HealthFormatter.percentage(0.0)    // → "0%"
    /// ```
    ///
    /// - Parameter fraction: A fractional value in `0...1`.
    /// - Returns: Formatted percentage string, e.g. `"72%"`.
    public static func percentage(_ fraction: Double) -> String {
        let clamped = min(max(fraction, 0.0), 1.0)
        return percentageNumberFormatter.string(from: NSNumber(value: clamped))
            ?? "\(Int(clamped * 100))%"
    }

    // MARK: - Water

    /// Returns a water intake string in millilitres.
    ///
    /// ```swift
    /// HealthFormatter.water(ml: 750)    // → "750 ml"
    /// HealthFormatter.water(ml: 2_000)  // → "2,000 ml"
    /// ```
    ///
    /// - Parameter ml: Volume in millilitres.
    /// - Returns: Formatted string, e.g. `"750 ml"`.
    public static func water(ml: Int) -> String {
        "\(waterNumberFormatter.string(from: NSNumber(value: ml)) ?? "\(ml)") ml"
    }

    /// Returns a water intake string formatted as whole litres when ≥ 1000 ml,
    /// or millilitres otherwise — useful for compact progress labels.
    ///
    /// ```swift
    /// HealthFormatter.waterCompact(ml: 750)    // → "750 ml"
    /// HealthFormatter.waterCompact(ml: 1_500)  // → "1.5 L"
    /// ```
    ///
    /// - Parameter ml: Volume in millilitres.
    /// - Returns: Compact formatted string.
    public static func waterCompact(ml: Int) -> String {
        if ml >= 1_000 {
            let litres = Double(ml) / 1_000.0
            return "\(temperatureNumberFormatter.string(from: NSNumber(value: litres)) ?? "\(litres)") L"
        }
        return "\(ml) ml"
    }

    // MARK: - Private Formatter Instances

    // Using a private enum as a namespace to hold lazily-allocated formatters.

    private static let weightNumberFormatter: NumberFormatter = {
        let f                    = NumberFormatter()
        f.numberStyle            = .decimal
        f.minimumFractionDigits  = 1
        f.maximumFractionDigits  = 1
        f.locale                 = .current
        return f
    }()

    private static let temperatureNumberFormatter: NumberFormatter = {
        let f                    = NumberFormatter()
        f.numberStyle            = .decimal
        f.minimumFractionDigits  = 1
        f.maximumFractionDigits  = 1
        f.locale                 = .current
        return f
    }()

    private static let percentageNumberFormatter: NumberFormatter = {
        let f                    = NumberFormatter()
        f.numberStyle            = .percent
        f.minimumFractionDigits  = 0
        f.maximumFractionDigits  = 0
        f.locale                 = .current
        return f
    }()

    private static let waterNumberFormatter: NumberFormatter = {
        let f                    = NumberFormatter()
        f.numberStyle            = .decimal
        f.minimumFractionDigits  = 0
        f.maximumFractionDigits  = 0
        f.usesGroupingSeparator  = true
        f.locale                 = .current
        return f
    }()
}
