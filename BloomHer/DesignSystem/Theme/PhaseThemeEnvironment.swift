//
//  PhaseThemeEnvironment.swift
//  BloomHer
//
//  SwiftUI environment keys that propagate the active cycle phase and app
//  mode down the view hierarchy without requiring explicit prop drilling.
//
//  Usage:
//    // Inject at the root:
//    ContentView()
//        .environment(\.currentCyclePhase, viewModel.currentPhase)
//        .environment(\.appMode, .cycle)
//
//    // Read anywhere in the tree:
//    @Environment(\.currentCyclePhase) private var phase
//    @Environment(\.appMode)           private var mode
//

import SwiftUI

// MARK: - CurrentCyclePhase Environment Key

private struct CurrentCyclePhaseKey: EnvironmentKey {
    /// Defaults to `.follicular` — the phase directly following menstruation,
    /// a natural starting point for new or untracked users.
    static let defaultValue: CyclePhase = .follicular
}

// MARK: - AppMode Environment Key

private struct AppModeKey: EnvironmentKey {
    /// Defaults to `.cycle` — the primary use case of the app.
    static let defaultValue: AppMode = .cycle
}

// MARK: - EnvironmentValues Extensions

extension EnvironmentValues {

    /// The cycle phase currently active for the authenticated user.
    ///
    /// Inject this at the scene root after resolving the user's tracking data
    /// so that phase-aware components (phase header, gradient backgrounds,
    /// phase glow shadows) all update from a single source.
    var currentCyclePhase: CyclePhase {
        get { self[CurrentCyclePhaseKey.self] }
        set { self[CurrentCyclePhaseKey.self] = newValue }
    }

    /// The tracking mode the user has selected.
    ///
    /// Views can adapt their content, copy, and navigation options based on
    /// this value without needing to query the data layer directly.
    var appMode: AppMode {
        get { self[AppModeKey.self] }
        set { self[AppModeKey.self] = newValue }
    }
}
