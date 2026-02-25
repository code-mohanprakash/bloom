//
//  ProfileRouter.swift
//  BloomHer
//
//  Manages the NavigationPath for the Profile tab's NavigationStack.
//

import SwiftUI

// MARK: - ProfileRouter

/// Controls push-navigation for the Profile / Settings tab.
@Observable
final class ProfileRouter {

    // MARK: - State

    /// The live navigation path bound to the Profile tab's NavigationStack.
    var path = NavigationPath()

    // MARK: - Navigation Actions

    /// Pushes a `ProfileDestination` onto the navigation stack.
    ///
    /// - Parameter destination: The screen to navigate to.
    func navigate(to destination: ProfileDestination) {
        path.append(destination)
    }

    /// Pops the top-most screen from the stack.
    ///
    /// Safe to call when the stack is empty — does nothing in that case.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pops all screens and returns to the Profile root view.
    func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }
}
