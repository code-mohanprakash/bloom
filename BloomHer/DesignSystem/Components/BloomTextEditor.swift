//
//  BloomTextEditor.swift
//  BloomHer
//
//  A multi-line themed text editor with a placeholder overlay,
//  surface background, and a rounded rectangle border that animates
//  to rose on focus.
//

import SwiftUI

// MARK: - BloomTextEditor

/// A themed multi-line text editor for BloomHer forms.
///
/// Because `TextEditor` does not natively support a placeholder, `BloomTextEditor`
/// overlays placeholder text when the binding is empty. The editor respects a
/// configurable minimum height and grows vertically with content.
///
/// ```swift
/// @State private var journalEntry = ""
///
/// BloomTextEditor(
///     placeholder: "How are you feeling today?",
///     text: $journalEntry,
///     minHeight: 120
/// )
/// ```
public struct BloomTextEditor: View {

    // MARK: Configuration

    private let placeholder: String
    @Binding private var text: String
    private let minHeight: CGFloat

    // MARK: State

    @FocusState private var isFocused: Bool

    // MARK: Init

    /// Creates a `BloomTextEditor`.
    ///
    /// - Parameters:
    ///   - placeholder: Hint text shown when the editor is empty.
    ///   - text: Binding to the current string value.
    ///   - minHeight: The editor's minimum vertical height in points. Defaults to `100`.
    public init(
        placeholder: String,
        text: Binding<String>,
        minHeight: CGFloat = 100
    ) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
    }

    // MARK: Body

    public var body: some View {
        ZStack(alignment: .topLeading) {
            // Editor
            TextEditor(text: $text)
                .focused($isFocused)
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: minHeight)
                .padding(BloomHerTheme.Spacing.xs)

            // Placeholder overlay
            if text.isEmpty {
                Text(placeholder)
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    .padding(.horizontal, BloomHerTheme.Spacing.xs + 4)
                    .padding(.top, BloomHerTheme.Spacing.xs + 8)
                    .allowsHitTesting(false)
            }
        }
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

#Preview("Bloom Text Editor") {
    TextEditorPreviewContainer()
}

private struct TextEditorPreviewContainer: View {
    @State private var journal = ""
    @State private var notes = "I've been feeling really energetic this week. The ovulation phase always gives me such a productivity boost."

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                Text("Journal Entry").font(BloomHerTheme.Typography.subheadline).foregroundStyle(BloomHerTheme.Colors.textPrimary)
                BloomTextEditor(placeholder: "How are you feeling today?", text: $journal, minHeight: 120)
            }

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                Text("Notes (Pre-filled)").font(BloomHerTheme.Typography.subheadline).foregroundStyle(BloomHerTheme.Colors.textPrimary)
                BloomTextEditor(placeholder: "Add notes...", text: $notes, minHeight: 80)
            }
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(BloomHerTheme.Colors.background)
    }
}
