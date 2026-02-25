//
//  WellnessRouter.swift
//  BloomHer
//
//  Manages the NavigationPath for the Wellness tab's NavigationStack.
//

import SwiftUI

// MARK: - WellnessRouter

/// Controls push-navigation for the Wellness tab.
@Observable
final class WellnessRouter {

    // MARK: - State

    /// The live navigation path bound to the Wellness tab's NavigationStack.
    var path = NavigationPath()

    // MARK: - Navigation Actions

    /// Pushes a `WellnessDestination` onto the navigation stack.
    ///
    /// - Parameter destination: The screen to navigate to.
    func navigate(to destination: WellnessDestination) {
        path.append(destination)
    }

    /// Pops the top-most screen from the stack.
    ///
    /// Safe to call when the stack is empty — does nothing in that case.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pops all screens and returns to the Wellness root view.
    func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }
}
