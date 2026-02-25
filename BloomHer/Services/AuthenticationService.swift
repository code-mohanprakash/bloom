//
//  AuthenticationService.swift
//  BloomHer
//
//  Handles Sign in with Apple authentication.
//  Stores the Apple user ID in Keychain for persistence across installs.
//  Provides observable auth state for UI reactivity.
//
//  Requires the "Sign in with Apple" capability in the Xcode project.
//

import AuthenticationServices
import Foundation
import Security

// MARK: - AuthenticationService

/// Manages Apple ID credential state and user identity.
///
/// On launch, call `checkExistingCredential()` to silently verify the
/// stored Apple user ID is still valid.  If the user has not yet
/// signed in, `authState` will be `.signedOut`.
@Observable
@MainActor
final class AuthenticationService {

    // MARK: - Published State

    /// Current authentication state.
    var authState: AuthState = .signedOut

    /// Display name from the Apple ID credential (first sign-in only).
    var userName: String?

    /// Email from the Apple ID credential (first sign-in only).
    var userEmail: String?

    /// Error message from the most recent failed operation.
    var errorMessage: String?

    // MARK: - Auth State Enum

    enum AuthState: Equatable {
        case signedOut
        case signedIn
        case checking
    }

    // MARK: - Constants

    private static let keychainKey = "com.bloomher.appleUserID"

    // MARK: - Check Existing Credential

    /// Silently verify that the stored Apple user ID is still authorised.
    ///
    /// Call this on app launch.  If the credential is revoked or not found,
    /// `authState` is set to `.signedOut`.
    func checkExistingCredential() {
        guard let userID = Self.loadUserID() else {
            authState = .signedOut
            return
        }

        authState = .checking

        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userID) { [weak self] state, _ in
            Task { @MainActor in
                guard let self else { return }
                switch state {
                case .authorized:
                    self.authState = .signedIn
                case .revoked, .notFound:
                    Self.deleteUserID()
                    self.authState = .signedOut
                    self.userName = nil
                    self.userEmail = nil
                default:
                    self.authState = .signedOut
                }
            }
        }
    }

    // MARK: - Handle Sign-In Result

    /// Process the `ASAuthorizationAppleIDCredential` returned by
    /// `SignInWithAppleButton` or a manual `ASAuthorizationController` flow.
    ///
    /// - Parameter result: The authorization result.
    func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Unexpected credential type."
                return
            }

            // Persist the user identifier in Keychain
            Self.saveUserID(credential.user)

            // Name and email are only sent on the FIRST sign-in
            if let fullName = credential.fullName {
                let parts = [fullName.givenName, fullName.familyName].compactMap { $0 }
                if !parts.isEmpty {
                    userName = parts.joined(separator: " ")
                }
            }
            if let email = credential.email {
                userEmail = email
            }

            authState = .signedIn
            errorMessage = nil

        case .failure(let error):
            // ASAuthorizationError.canceled is expected (user dismissed the sheet)
            if (error as? ASAuthorizationError)?.code == .canceled {
                return
            }
            errorMessage = error.localizedDescription
            authState = .signedOut
        }
    }

    // MARK: - Sign Out

    /// Signs the user out locally by clearing Keychain state.
    func signOut() {
        Self.deleteUserID()
        authState = .signedOut
        userName = nil
        userEmail = nil
        errorMessage = nil
    }

    // MARK: - Keychain Helpers

    private static func saveUserID(_ userID: String) {
        guard let data = userID.data(using: .utf8) else { return }
        // Delete any existing entry first
        deleteUserID()

        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String:   data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private static func loadUserID() -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let userID = String(data: data, encoding: .utf8) else {
            return nil
        }
        return userID
    }

    private static func deleteUserID() {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey
        ]
        SecItemDelete(query as CFDictionary)
    }
}
