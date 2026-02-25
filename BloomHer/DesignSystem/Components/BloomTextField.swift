//
//  BloomTextField.swift
//  BloomHer
//
//  A single-line themed text field with an optional leading SF Symbol icon,
//  a rose focus ring animation, and surface-colored background.
//

import SwiftUI

// MARK: - BloomTextField

/// A themed single-line text input field for BloomHer forms.
///
/// Features:
/// - Optional leading SF Symbol icon in `primaryRose`.
/// - `RoundedRectangle` border at `Radius.medium` that animates to rose when focused.
/// - Surface-colored background (`BloomColors.surface`).
/// - Accepts any `KeyboardType` and `SubmitLabel`.
///
/// ```swift
/// @State private var email = ""
/// @FocusState private var focused: Bool
///
/// BloomTextField(
///     placeholder: "your@email.com",
///     icon: "envelope",
///     text: $email
/// )
/// ```
public struct BloomTextField: View {

    // MARK: Configuration

    private let placeholder: String
    private let icon: String?
    @Binding private var text: String
    private let keyboardType: UIKeyboardType
    private let submitLabel: SubmitLabel
    private let onSubmit: (() -> Void)?

    // MARK: State

    @FocusState private var isFocused: Bool

    // MARK: Init

    /// Creates a `BloomTextField`.
    ///
    /// - Parameters:
    ///   - placeholder: Hint text shown when the field is empty.
    ///   - icon: Optional SF Symbol name displayed inside the leading edge.
    ///   - text: Binding to the current string value.
    ///   - keyboardType: The keyboard type. Defaults to `.default`.
    ///   - submitLabel: The return-key label. Defaults to `.done`.
    ///   - onSubmit: Optional closure called when the user submits.
    public init(
        placeholder: String,
        icon: String? = nil,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        submitLabel: SubmitLabel = .done,
        onSubmit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.keyboardType = keyboardType
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
    }

    // MARK: Body

    public var body: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            if let icon {
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    .frame(width: 20)
            }

            TextField(placeholder, text: $text)
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .keyboardType(keyboardType)
                .submitLabel(submitLabel)
                .focused($isFocused)
                .onSubmit { onSubmit?() }
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)
        .padding(.vertical, BloomHerTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                .fill(BloomHerTheme.Colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                .strokeBorder(
                    isFocused ? BloomHerTheme.Colors.primaryRose : Color.primary.opacity(0.12),
                    lineWidth: isFocused ? 2 : 1
                )
                .animation(BloomHerTheme.Animation.quick, value: isFocused)
        )
        .onTapGesture {
            isFocused = true
        }
    }
}

// MARK: - Preview

#Preview("Bloom Text Field") {
    TextFieldPreviewContainer()
}

private struct TextFieldPreviewContainer: View {
    @State private var name = ""
    @State private var email = ""
    @State private var notes = "Already has text"

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            // With icon, empty
            BloomTextField(placeholder: "Full name", icon: "person", text: $name)

            // With icon, email keyboard
            BloomTextField(
                placeholder: "Email address",
                icon: "envelope",
                text: $email,
                keyboardType: .emailAddress,
                submitLabel: .next
            )

            // No icon, prefilled
            BloomTextField(placeholder: "Notes", text: $notes)

            // Number input
            BloomTextField(
                placeholder: "Cycle length (days)",
                icon: "calendar",
                text: .constant("28"),
                keyboardType: .numberPad
            )
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(BloomHerTheme.Colors.background)
    }
}
