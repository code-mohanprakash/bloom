//
//  AIFloatingButton.swift
//  BloomHer
//
//  A subtle frosted-glass "Ask Bloom" pill that floats above the tab bar.
//  Uses the app's dove brand icon and adapts to light/dark via ultraThinMaterial.
//

import SwiftUI

// MARK: - AIFloatingButton

struct AIFloatingButton: View {

    @Binding var isPresented: Bool
    let isGenerating: Bool

    // MARK: Animation State

    @State private var doveAngle: Double = 0.0

    // MARK: Body

    var body: some View {
        Button {
            BloomHerTheme.Haptics.medium()
            isPresented.toggle()
        } label: {
            HStack(spacing: 6) {
                // ── Dove brand icon ─────────────────────────────────────────
                Image(BloomIcons.dove)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .rotationEffect(.degrees(doveAngle))

                // ── Label or typing dots ────────────────────────────────────
                if isGenerating {
                    BloomingIndicator()
                } else {
                    Text("Ask Bloom")
                        .font(BloomHerTheme.Typography.caption2.weight(.semibold))
                }
            }
            .foregroundStyle(.primary.opacity(0.75))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(.primary.opacity(0.08), lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .onChange(of: isGenerating) { _, generating in
            if generating {
                startSpinAnimation()
            } else {
                stopSpinAnimation()
            }
        }
        .accessibilityLabel("Ask Bloom assistant")
    }

    // MARK: - Animations

    private func startSpinAnimation() {
        withAnimation(
            .linear(duration: 2.0).repeatForever(autoreverses: false)
        ) {
            doveAngle = 360
        }
    }

    private func stopSpinAnimation() {
        withAnimation(BloomHerTheme.Animation.gentle) {
            doveAngle = 0
        }
    }
}
