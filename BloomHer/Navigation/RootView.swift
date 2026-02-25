//
//  RootView.swift
//  BloomHer
//
//  The top-level conditional view that gates the app on whether the user
//  has completed onboarding. It observes `SettingsManager.hasCompletedOnboarding`
//  and transitions from `OnboardingFlow` to `MainTabView` (or vice versa for
//  account resets) using a fade + vertical slide animation.
//
//  Design decisions
//  ----------------
//  - The transition is intentionally gentle (easeInOut, 0.4 s) so that the
//    switch from onboarding to the main app feels like an arrival rather than
//    an abrupt cut.
//  - `id:` keying on `hasCompletedOnboarding` forces SwiftUI to fully replace
//    the view tree rather than attempt a diffed update, which prevents a
//    momentary flash of the previous screen's content during the transition.
//

import SwiftUI

// MARK: - RootView

struct RootView: View {

    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        Group {
            if dependencies.settingsManager.hasCompletedOnboarding {
                MainTabView()
                    .transition(appTransition)
            } else {
                OnboardingFlow()
                    .transition(appTransition)
            }
        }
        // id-keying triggers a complete view-tree replacement — and therefore
        // the .transition — whenever the flag flips in either direction.
        .id(dependencies.settingsManager.hasCompletedOnboarding)
        .animation(
            .easeInOut(duration: 0.40),
            value: dependencies.settingsManager.hasCompletedOnboarding
        )
    }

    // MARK: - Transition

    /// A combined fade and upward-slide entrance used for both branches so
    /// the transition reads as a forward progression through the app lifecycle.
    private var appTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(
                with: .move(edge: .bottom)
            ),
            removal: .opacity
        )
    }
}

// MARK: - Preview

#Preview("Root — Onboarding") {
    RootView()
        .environment(AppDependencies.preview())
        .modelContainer(DataConfiguration.makeInMemoryContainer())
}

#Preview("Root — Main App") {
    // Simulate a user who has already completed onboarding.
    let deps = AppDependencies.preview()
    deps.settingsManager.hasCompletedOnboarding = true

    return RootView()
        .environment(deps)
        .modelContainer(DataConfiguration.makeInMemoryContainer())
}
