//
//  AIAssistantChatView.swift
//  BloomHer
//
//  Liquid glass chat interface for the Bloom AI assistant.
//  Presents as a sheet from the floating AIFloatingButton.
//
//  Haptic pattern
//  --------------
//  - Send message:       light tap
//  - AI response starts: medium tap
//  - Every 8 chunks:     selection tick (typing rhythm)
//  - Response complete:  success
//

import SwiftUI

// MARK: - AIAssistantChatView

struct AIAssistantChatView: View {

    // MARK: Dependencies

    let service: AIAssistantService

    // MARK: State

    @State private var inputText:       String = ""
    @State private var scrollProxy:     ScrollViewProxy?
    @State private var showClearAlert:  Bool   = false
    @FocusState private var inputFocused: Bool
    @Environment(\.dismiss) private var dismiss

    // MARK: Body

    var body: some View {
        ZStack {
            // ── Glass background ─────────────────────────────────────────────
            BloomHerTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                Divider().opacity(0.15)

                if service.availability.isAvailable {
                    availableContent
                } else {
                    unavailableContent
                }
            }
        }
        .alert("Clear conversation?", isPresented: $showClearAlert) {
            Button("Clear", role: .destructive) { service.clearHistory() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove all messages and start a fresh session.")
        }
        // Haptic: pulse every 8 response chunks (typing rhythm)
        .onChange(of: service.chunkCount) { _, count in
            if count % 8 == 0 && count > 0 && service.isGenerating {
                BloomHerTheme.Haptics.selection()
            }
        }
        // Haptic: success when generation finishes
        .onChange(of: service.isGenerating) { _, generating in
            if !generating && !service.messages.isEmpty {
                BloomHerTheme.Haptics.success()
            }
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            // AI icon + title
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    BloomHerTheme.Colors.primaryRose,
                                    BloomHerTheme.Colors.accentLavender,
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)

                    Image(BloomIcons.dove)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Ask Bloom")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("On-device · Private")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }
            }

            Spacer()

            // Blooming indicator
            if service.isGenerating {
                HStack(spacing: 4) {
                    BloomingIndicator()
                    Text("Blooming…")
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }

            // Clear button
            Button {
                showClearAlert = true
            } label: {
                Image(BloomIcons.trash)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
            .buttonStyle(ScaleButtonStyle())

            // Dismiss
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(BloomHerTheme.Colors.textTertiary.opacity(0.12))
                        .frame(width: 28, height: 28)
                    Image(BloomIcons.xmark)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)
        .padding(.vertical, BloomHerTheme.Spacing.sm)
        .background(.ultraThinMaterial)
        .animation(BloomHerTheme.Animation.quick, value: service.isGenerating)
    }

    // MARK: - Available Content

    private var availableContent: some View {
        VStack(spacing: 0) {
            messageList
            inputBar
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: BloomHerTheme.Spacing.sm) {
                    // AI disclaimer pill at top
                    Text("AI-generated · Not medical advice")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        .padding(.horizontal, BloomHerTheme.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(BloomHerTheme.Colors.textTertiary.opacity(0.1))
                        )
                        .padding(.top, BloomHerTheme.Spacing.md)

                    ForEach(service.messages) { message in
                        AIMessageBubble(message: message)
                            .id(message.id)
                    }

                    Color.clear.frame(height: 8).id("bottom")
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)
            }
            .onAppear { scrollProxy = proxy }
            .onChange(of: service.messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: service.chunkCount) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(BloomHerTheme.Animation.quick) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.15)

            HStack(spacing: BloomHerTheme.Spacing.sm) {
                TextField("Ask anything…", text: $inputText, axis: .vertical)
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .lineLimit(1...5)
                    .focused($inputFocused)
                    .submitLabel(.send)
                    .onSubmit { sendMessage() }
                    .padding(.horizontal, BloomHerTheme.Spacing.sm)
                    .padding(.vertical, BloomHerTheme.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                            .fill(BloomHerTheme.Colors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                                    .strokeBorder(BloomHerTheme.Colors.textTertiary.opacity(0.2), lineWidth: 1)
                            )
                    )

                // Send button
                Button {
                    sendMessage()
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                canSend
                                    ? LinearGradient(
                                        colors: [BloomHerTheme.Colors.primaryRose, BloomHerTheme.Colors.accentLavender],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                      )
                                    : LinearGradient(
                                        colors: [BloomHerTheme.Colors.textTertiary.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                      )
                            )
                            .frame(width: 36, height: 36)

                        Image(BloomIcons.arrowUpCircle)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(!canSend)
                .animation(BloomHerTheme.Animation.quick, value: canSend)
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .padding(.vertical, BloomHerTheme.Spacing.sm)
            .background(.ultraThinMaterial)
        }
    }

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !service.isGenerating
    }

    private func sendMessage() {
        guard canSend else { return }
        let text = inputText
        inputText = ""
        BloomHerTheme.Haptics.light()
        // Medium haptic when AI starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            BloomHerTheme.Haptics.medium()
        }
        Task { await service.send(text) }
    }

    // MARK: - Unavailable Content

    private var unavailableContent: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(BloomHerTheme.Colors.primaryRose.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(BloomIcons.dove)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            }

            VStack(spacing: BloomHerTheme.Spacing.xs) {
                Text("Ask Bloom Unavailable")
                    .font(BloomHerTheme.Typography.title3)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                Text(service.availability.message ?? "Apple Intelligence is required.")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BloomHerTheme.Spacing.xl)

                if service.availability == .unavailable("Enable Apple Intelligence in Settings → Apple Intelligence & Siri.") {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    .padding(.top, BloomHerTheme.Spacing.xs)
                }
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - AIMessageBubble

private struct AIMessageBubble: View {
    let message: AIMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: BloomHerTheme.Spacing.xs) {
            if message.isUser {
                Spacer(minLength: 44)
                userBubble
            } else {
                aiBubble
                Spacer(minLength: 44)
            }
        }
    }

    private var userBubble: some View {
        Text(message.content)
            .font(BloomHerTheme.Typography.body)
            .foregroundStyle(.white)
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .padding(.vertical, BloomHerTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [BloomHerTheme.Colors.primaryRose, BloomHerTheme.Colors.accentLavender],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .transition(.move(edge: .trailing).combined(with: .opacity))
    }

    private var aiBubble: some View {
        VStack(alignment: .leading, spacing: 0) {
            if message.content.isEmpty {
                BloomingIndicator()
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .padding(.vertical, BloomHerTheme.Spacing.sm)
            } else {
                Text(message.content)
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .padding(.vertical, BloomHerTheme.Spacing.sm)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    BloomHerTheme.Colors.primaryRose.opacity(0.25),
                                    BloomHerTheme.Colors.accentLavender.opacity(0.15),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .frame(maxWidth: 280, alignment: .leading)
        .transition(.move(edge: .leading).combined(with: .opacity))
    }
}

// MARK: - BloomingIndicator

/// A flower-petal bloom animation used throughout the app to indicate
/// that content is being prepared. Five petals radiate from a center point
/// and pulse sequentially, evoking a flower opening.
struct BloomingIndicator: View {

    @State private var isAnimating = false

    private let petalCount = 5

    var body: some View {
        ZStack {
            // Petals arranged in a circle
            ForEach(0..<petalCount, id: \.self) { i in
                Circle()
                    .fill(BloomHerTheme.Colors.primaryRose.opacity(0.8))
                    .frame(width: 6, height: 6)
                    .offset(y: -8)
                    .rotationEffect(.degrees(Double(i) * 72))
                    .scaleEffect(isAnimating ? 1.0 : 0.2)
                    .opacity(isAnimating ? 1.0 : 0.2)
                    .animation(
                        .easeInOut(duration: 0.7)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.12),
                        value: isAnimating
                    )
            }

            // Center pistil
            Circle()
                .fill(BloomHerTheme.Colors.accentPeach)
                .frame(width: 5, height: 5)
                .scaleEffect(isAnimating ? 1.2 : 0.7)
                .animation(
                    .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .frame(width: 24, height: 24)
        .onAppear { isAnimating = true }
    }
}

// MARK: - Preview

#Preview("AI Chat") {
    let deps = AppDependencies.preview()
    let _ = deps.aiAssistantService.configure(
        mode: .cycle,
        phase: .follicular,
        userName: "Sarah"
    )
    return AIAssistantChatView(service: deps.aiAssistantService)
        .environment(deps)
}
