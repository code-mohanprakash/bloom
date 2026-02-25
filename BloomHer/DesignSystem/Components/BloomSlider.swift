//
//  BloomSlider.swift
//  BloomHer
//
//  A themed wrapper around SwiftUI's native `Slider` that applies BloomHer
//  design tokens — tinted track, themed label typography, and a value label
//  closure. Not a custom implementation; it delegates to the system control
//  for full accessibility support.
//

import SwiftUI

// MARK: - BloomSlider

/// A themed wrapper around the system `Slider`.
///
/// Provides consistent label typography, rose tinting, and an optional
/// formatted value label without re-implementing slider interaction logic.
/// The system `Slider` is used directly so VoiceOver, Dynamic Type, and
/// step increments all work out of the box.
///
/// ```swift
/// @State private var temperature: Double = 36.6
///
/// BloomSlider(
///     value: $temperature,
///     in: 35.0...42.0,
///     step: 0.1,
///     label: "Temperature"
/// ) { value in
///     Text(String(format: "%.1f°C", value))
/// }
/// ```
public struct BloomSlider<ValueLabel: View>: View {

    // MARK: Configuration

    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let label: String
    private let trackColor: Color
    private let valueLabel: (Double) -> ValueLabel

    // MARK: Init

    /// Creates a `BloomSlider`.
    ///
    /// - Parameters:
    ///   - value: Binding to the current slider value.
    ///   - range: The valid range of values. Defaults to `0...1`.
    ///   - step: The increment between values. Defaults to `0.01`.
    ///   - label: Descriptive label shown above the slider.
    ///   - trackColor: The tint color for the filled track. Defaults to `primaryRose`.
    ///   - valueLabel: A `@ViewBuilder` closure that receives the current value and
    ///     returns a formatted label shown to the trailing side of the slider.
    public init(
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...1,
        step: Double = 0.01,
        label: String,
        trackColor: Color = BloomHerTheme.Colors.primaryRose,
        @ViewBuilder valueLabel: @escaping (Double) -> ValueLabel
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.label = label
        self.trackColor = trackColor
        self.valueLabel = valueLabel
    }

    // MARK: Body

    public var body: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
            // Label row
            HStack {
                Text(label)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Spacer()
                valueLabel(value)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .monospacedDigit()
            }

            // Slider
            Slider(value: $value, in: range, step: step)
                .tint(trackColor)
        }
    }
}

// MARK: - Convenience init (no value label)

extension BloomSlider where ValueLabel == EmptyView {

    /// Creates a `BloomSlider` without a value label.
    ///
    /// - Parameters:
    ///   - value: Binding to the current slider value.
    ///   - range: The valid range.
    ///   - step: The increment.
    ///   - label: Descriptive label above the slider.
    ///   - trackColor: Tint color for the filled track. Defaults to `primaryRose`.
    public init(
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...1,
        step: Double = 0.01,
        label: String,
        trackColor: Color = BloomHerTheme.Colors.primaryRose
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.label = label
        self.trackColor = trackColor
        self.valueLabel = { _ in EmptyView() }
    }
}

// MARK: - Preview

#Preview("Bloom Slider") {
    SliderPreviewContainer()
}

private struct SliderPreviewContainer: View {
    @State private var temperature: Double = 36.6
    @State private var painLevel: Double = 3
    @State private var cycleDay: Double = 14

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.xl) {
            BloomSlider(value: $temperature, in: 35.0...42.0, step: 0.1, label: "Basal Body Temperature") { value in
                Text(String(format: "%.1f°C", value))
            }

            BloomSlider(
                value: $painLevel,
                in: 0...10,
                step: 1,
                label: "Pain Level",
                trackColor: BloomHerTheme.Colors.phase(.menstrual)
            ) { value in
                Text("\(Int(value))/10")
            }

            BloomSlider(
                value: $cycleDay,
                in: 1...35,
                step: 1,
                label: "Cycle Day",
                trackColor: BloomHerTheme.Colors.sageGreen
            ) { value in
                Text("Day \(Int(value))")
            }

            // No value label
            BloomSlider(value: $temperature, in: 35.0...42.0, step: 0.1, label: "Temperature (no label)")
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(BloomHerTheme.Colors.background)
    }
}
