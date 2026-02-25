//
//  InsightsRouter.swift
//  BloomHer
//
//  Manages the NavigationPath for the Insights tab's NavigationStack.
//

import SwiftUI

// MARK: - InsightsRouter

/// Controls push-navigation for the Insights tab.
@Observable
final class InsightsRouter {

    // MARK: - State

    /// The live navigation path bound to the Insights tab's NavigationStack.
    var path = NavigationPath()

    // MARK: - Navigation Actions

    /// Pushes an `InsightsDestination` onto the navigation stack.
    ///
    /// - Parameter destination: The screen to navigate to.
    func navigate(to destination: InsightsDestination) {
        path.append(destination)
    }

    /// Pops the top-most screen from the stack.
    ///
    /// Safe to call when the stack is empty — does nothing in that case.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pops all screens and returns to the Insights root view.
    func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }
}
