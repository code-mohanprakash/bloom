//
//  HapticManager.swift
//  BloomHer
//
//  A user-preference-aware wrapper around `BloomHerTheme.Haptics`.
//
//  All haptic calls in feature views should go through `HapticManager` rather
//  than calling `BloomHerTheme.Haptics` directly. This single chokepoint
//  ensures that users who have disabled haptics in Settings → BloomHer never
//  receive unintended tactile feedback.
//
//  Usage:
//    HapticManager.shared.light()
//    HapticManager.shared.success()
//
//  To disable haptics in tests or Previews:
//    HapticManager.shared.isEnabled = false
//

import Foundation

// MARK: - HapticManager

/// Mediates haptic feedback so it only fires when the user has opted in.
///
/// The opt-in state is persisted in `UserDefaults` under the key
/// `"hapticsEnabled"` and defaults to `true` on first launch.
@MainActor
public final class HapticManager {

    // MARK: Shared Instance

    /// The singleton shared across the app.
    public static let shared = HapticManager()

    // MARK: UserDefaults Key

    private enum DefaultsKey {
        static let hapticsEnabled = "hapticsEnabled"
    }

    // MARK: Preference

    /// Whether haptic feedback is currently enabled.
    ///
    /// Setting this property persists the value to `UserDefaults` immediately.
    public var isEnabled: Bool {
        get { UserDefaults.standard.object(forKey: DefaultsKey.hapticsEnabled) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: DefaultsKey.hapticsEnabled) }
    }

    // MARK: Init

    /// Private — use `HapticManager.shared`.
    private init() {}

    // MARK: - Feedback Methods

    /// Light impact feedback — taps, row selections.
    ///
    /// Maps to `UIImpactFeedbackGenerator(style: .light)`.
    public func light() {
        guard isEnabled else { return }
        BloomHerTheme.Haptics.light()
    }

    /// Medium impact feedback — confirmations, toggle changes.
    ///
    /// Maps to `UIImpactFeedbackGenerator(style: .medium)`.
    public func medium() {
        guard isEnabled else { return }
        BloomHerTheme.Haptics.medium()
    }

    /// Success notification feedback — completed log entries, saved data.
    ///
    /// Maps to `UINotificationFeedbackGenerator` with `.success` type.
    public func success() {
        guard isEnabled else { return }
        BloomHerTheme.Haptics.success()
    }

    /// Selection feedback — picker / segment scrolls.
    ///
    /// Maps to `UISelectionFeedbackGenerator`.
    public func selection() {
        guard isEnabled else { return }
        BloomHerTheme.Haptics.selection()
    }

    /// Error notification feedback — validation failures, destructive actions.
    ///
    /// Maps to `UINotificationFeedbackGenerator` with `.error` type.
    public func error() {
        guard isEnabled else { return }
        BloomHerTheme.Haptics.error()
    }
}
