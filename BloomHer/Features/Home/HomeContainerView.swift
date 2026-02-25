//
//  HomeContainerView.swift
//  BloomHer
//
//  Wrapper view that switches the root Home content based on the user's
//  selected AppMode. Each mode surfaces a tailored dashboard.
//

import SwiftUI

// MARK: - HomeContainerView

/// Routes the Home tab to the correct dashboard based on `appMode`.
///
/// `HomeContainerView` is the view bound to the Home tab bar item. It reads
/// `AppMode` from `AppDependencies.settingsManager` (which is `@Observable`)
/// so the switch is reactive — changing mode in Settings immediately
/// transitions the user to the right dashboard without relaunching.
///
/// - `.cycle`    → `HomeView` — standard menstrual cycle tracking.
/// - `.pregnant` → `PregnancyDashboardView`.
/// - `.ttc`      → `TTCDashboardView`.
struct HomeContainerView: View {

    // MARK: - Environment

    @Environment(AppDependencies.self) private var dependencies

    // MARK: - Body

    var body: some View {
        switch dependencies.settingsManager.appMode {
        case .cycle:
            HomeView(dependencies: dependencies)

        case .pregnant:
            PregnancyDashboardView(dependencies: dependencies)

        case .ttc:
            TTCDashboardView(dependencies: dependencies)
        }
    }
}

// MARK: - Preview

#Preview("Home Container — Cycle") {
    let deps = AppDependencies.preview()
    deps.settingsManager.appMode = .cycle
    return HomeContainerView()
        .environment(deps)
}

#Preview("Home Container — Pregnant") {
    let deps = AppDependencies.preview()
    deps.settingsManager.appMode = .pregnant
    return HomeContainerView()
        .environment(deps)
}

#Preview("Home Container — TTC") {
    let deps = AppDependencies.preview()
    deps.settingsManager.appMode = .ttc
    return HomeContainerView()
        .environment(deps)
}
