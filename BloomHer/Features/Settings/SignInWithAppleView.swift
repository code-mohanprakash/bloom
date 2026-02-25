//
//  SignInWithAppleView.swift
//  BloomHer
//
//  A themed Sign in with Apple button and signed-in account card.
//  Wraps `SignInWithAppleButton` from AuthenticationServices and
//  delegates credential handling to `AuthenticationService`.
//

import AuthenticationServices
import SwiftUI

// MARK: - SignInWithAppleView

/// Shows either the Apple sign-in button or the signed-in account card,
/// depending on the current `AuthenticationService.authState`.
struct SignInWithAppleView: View {

    // MARK: - Dependencies

    @Bindable var authService: AuthenticationService

    // MARK: - Body

    var body: some View {
        switch authService.authState {
        case .signedOut:
            signInContent
        case .checking:
            checkingContent
        case .signedIn:
            signedInContent
        }
    }

    // MARK: - Signed Out

    private var signInContent: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                authService.handleSignIn(result: result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous))

            if let error = authService.errorMessage {
                Text(error)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.error)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Checking

    private var checkingContent: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            ProgressView()
                .tint(BloomHerTheme.Colors.primaryRose)
            Text("Checking account...")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(BloomHerTheme.Spacing.md)
    }

    // MARK: - Signed In

    private var signedInContent: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            // User avatar circle
            ZStack {
                Circle()
                    .fill(BloomHerTheme.Colors.primaryRose.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(BloomIcons.person)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                if let name = authService.userName {
                    Text(name)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                } else {
                    Text("Apple Account")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                if let email = authService.userEmail {
                    Text(email)
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }

            Spacer()

            Button {
                BloomHerTheme.Haptics.light()
                authService.signOut()
            } label: {
                Text("Sign Out")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.error)
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}

// MARK: - Preview

#Preview("Sign In — Signed Out") {
    let service = AuthenticationService()
    SignInWithAppleView(authService: service)
        .padding()
        .background(BloomHerTheme.Colors.background)
}

#Preview("Sign In — Signed In") {
    let service = AuthenticationService()
    let _ = {
        service.authState = .signedIn
        service.userName = "Jane"
        service.userEmail = "jane@icloud.com"
    }()
    SignInWithAppleView(authService: service)
        .padding()
        .background(BloomHerTheme.Colors.background)
}
