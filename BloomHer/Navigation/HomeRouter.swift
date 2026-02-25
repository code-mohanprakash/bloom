//
//  HomeRouter.swift
//  BloomHer
//
//  Manages the NavigationPath for the Home tab's NavigationStack.
//
//  Routers are @Observable so that the NavigationStack's $path binding
//  reacts to programmatic pushes. Each tab owns exactly one router
//  that is created as @State inside MainTabView, keeping the navigation
//  state alive for the lifetime of the scene.
//
//  Usage:
//    router.navigate(to: .cycleDetail(Date()))
//    router.pop()
//    router.popToRoot()
//

import SwiftUI

// MARK: - HomeRouter

/// Controls push-navigation for the Home tab.
@Observable
final class HomeRouter {

    // MARK: - State

    /// The live navigation path bound to the Home tab's NavigationStack.
    var path = NavigationPath()

    // MARK: - Navigation Actions

    /// Pushes a `HomeDestination` onto the navigation stack.
    ///
    /// - Parameter destination: The screen to navigate to.
    func navigate(to destination: HomeDestination) {
        path.append(destination)
    }

    /// Pops the top-most screen from the stack.
    ///
    /// Safe to call when the stack is empty — does nothing in that case.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pops all screens and returns to the Home root view.
    func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }
}
