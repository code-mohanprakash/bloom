//
//  BloomButton.swift
//  BloomHer
//
//  A fully-themed, multi-variant button component for BloomHer.
//  Supports five visual styles (primary, secondary, outline, ghost, danger),
//  three size tiers, an optional leading SF Symbol icon, and haptic feedback.
//

import SwiftUI

// MARK: - Enums

/// Visual style variants for `BloomButton`.
public enum BloomButtonStyle: Hashable {
    /// Rose-peach gradient fill with white text — the primary call to action.
    case primary
    /// Sage green fill with white text — secondary actions.
    case secondary
    /// Transparent background with a rose border and rose text — tertiary actions.
    case outline
    /// No fill or border, rose text only — low-emphasis actions.
    case ghost
    /// Menstrual-red fill with white text — destructive or high-alert actions.
    case danger
}

/// Size tiers for `BloomButton`, controlling font and padding.
public enum BloomButtonSize: Hashable {
    /// Compact button for dense layouts (caption font, tight padding).
    case small
    /// The default button size (subheadline font, standard padding).
    case medium
    /// Large prominent button (headline font, generous padding).
    case large
}

// MARK: - BloomButton

/// A versatile, themed button component that adapts its appearance across
/// five visual styles and three size tiers.
///
/// ```swift
/// BloomButton("Save Changes", style: .primary) {
///     viewModel.save()
/// }
///
/// BloomButton("Delete", style: .danger, icon: "trash") {
///     viewModel.delete()
/// }
/// ```
public struct BloomButton: View {

    // MARK: Configuration

    private let label: String
    private let style: BloomButtonStyle
    private let size: BloomButtonSize
    private let icon: String?
    private let isFullWidth: Bool
    private let action: () -> Void

    // MARK: Init

    /// Creates a `BloomButton`.
    ///
    /// - Parameters:
    ///   - label: The button's text label.
    ///   - style: Visual style variant. Defaults to `.primary`.
    ///   - size: Size tier. Defaults to `.medium`.
    ///   - icon: Optional SF Symbol name shown before the label. Defaults to `nil`.
    ///   - isFullWidth: When `true`, the button expands to fill its container.
    ///     Defaults to `false`.
    ///   - action: Closure executed on tap.
    public init(
        _ label: String,
        style: BloomButtonStyle = .primary,
        size: BloomButtonSize = .medium,
        icon: String? = nil,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.style = style
        self.size = size
        self.icon = icon
        self.isFullWidth = isFullWidth
        self.action = action
    }

    // MARK: Body

    public var body: some View {
        Button {
            triggerHaptic()
            action()
        } label: {
            buttonLabel
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: Label

    @ViewBuilder
    private var buttonLabel: some View {
        HStack(spacing: BloomHerTheme.Spacing.xs) {
            if let icon {
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            Text(label)
                .font(labelFont)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .background(backgroundView)
        .overlay(borderOverlay)
        .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.pill, style: .continuous))
    }

    // MARK: Style-dependent values

    private var foregroundColor: Color {
        switch style {
        case .primary, .secondary, .danger:
            return .white
        case .outline, .ghost:
            return BloomHerTheme.Colors.primaryRose
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            BloomColors.primaryRose
        case .secondary:
            BloomColors.sageGreen
        case .danger:
            BloomColors.menstrual
        case .outline, .ghost:
            Color.clear
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if style == .outline {
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.pill, style: .continuous)
                .strokeBorder(BloomHerTheme.Colors.primaryRose, lineWidth: 1.5)
        }
    }

    // MARK: Size-dependent values

    private var labelFont: Font {
        switch size {
        case .small:  return BloomHerTheme.Typography.caption
        case .medium: return BloomHerTheme.Typography.subheadline
        case .large:  return BloomHerTheme.Typography.headline
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small:  return BloomHerTheme.Spacing.xxs
        case .medium: return BloomHerTheme.Spacing.sm
        case .large:  return BloomHerTheme.Spacing.md
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small:  return BloomHerTheme.Spacing.sm
        case .medium: return BloomHerTheme.Spacing.lg
        case .large:  return BloomHerTheme.Spacing.xl
        }
    }

    // MARK: Haptics

    private func triggerHaptic() {
        switch style {
        case .primary, .secondary:
            BloomHerTheme.Haptics.medium()
        case .outline, .ghost:
            BloomHerTheme.Haptics.light()
        case .danger:
            BloomHerTheme.Haptics.error()
        }
    }
}

// MARK: - Preview

#Preview("Bloom Button") {
    ScrollView {
        VStack(spacing: BloomHerTheme.Spacing.lg) {

            // Style variants
            Group {
                Text("Styles").font(BloomHerTheme.Typography.headline).foregroundStyle(BloomHerTheme.Colors.textPrimary).frame(maxWidth: .infinity, alignment: .leading)

                BloomButton("Primary Action", style: .primary, isFullWidth: true) { }
                BloomButton("Secondary Action", style: .secondary, isFullWidth: true) { }
                BloomButton("Outline Action", style: .outline, isFullWidth: true) { }
                BloomButton("Ghost Action", style: .ghost, isFullWidth: true) { }
                BloomButton("Danger Action", style: .danger, isFullWidth: true) { }
            }

            Divider()

            // Sizes
            Group {
                Text("Sizes").font(BloomHerTheme.Typography.headline).foregroundStyle(BloomHerTheme.Colors.textPrimary).frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    BloomButton("Small", style: .primary, size: .small) { }
                    BloomButton("Medium", style: .primary, size: .medium) { }
                    BloomButton("Large", style: .primary, size: .large) { }
                }
            }

            Divider()

            // With icons
            Group {
                Text("With Icons").font(BloomHerTheme.Typography.headline).foregroundStyle(BloomHerTheme.Colors.textPrimary).frame(maxWidth: .infinity, alignment: .leading)

                BloomButton("Save", style: .primary, icon: BloomIcons.checkmark, isFullWidth: true) { }
                BloomButton("Delete", style: .danger, icon: BloomIcons.trash, isFullWidth: true) { }
                BloomButton("Share", style: .outline, icon: BloomIcons.share, isFullWidth: true) { }
            }
        }
        .padding(BloomHerTheme.Spacing.md)
    }
    .background(BloomHerTheme.Colors.background)
}
