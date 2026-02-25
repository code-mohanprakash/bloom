//
//  AffirmationCardView.swift
//  BloomHer
//
//  Full-screen affirmation card experience.
//  Features:
//  • Phase-coloured gradient card background
//  • Large centred quote with serif-style sizing
//  • Swipe left/right gesture for next/previous
//  • Heart favourite button with scale + particle animation
//  • Category badge, share sheet, sparkle background particles
//

import SwiftUI

// MARK: - AffirmationCardView

struct AffirmationCardView: View {

    // MARK: State

    @Bindable var viewModel: WellnessViewModel
    @State private var dragOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1
    @State private var showShareSheet: Bool = false
    @State private var heartScale: CGFloat = 1
    @State private var showHeartParticles: Bool = false

    // MARK: Body

    var body: some View {
        ZStack {
            // Background wash
            BloomHerTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: BloomHerTheme.Spacing.xl) {
                // Category filter row
                categoryFilterRow

                // Card deck area
                ZStack {
                    if viewModel.allAffirmations.isEmpty {
                        emptyState
                    } else {
                        affirmationCard
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 400)

                // Bottom controls
                bottomControls
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .padding(.vertical, BloomHerTheme.Spacing.lg)
        }
        .bloomNavigation("Affirmations")
        .sheet(isPresented: $showShareSheet) {
            if let affirmation = currentAffirmation {
                ShareSheet(text: "\u{201C}\(affirmation.text)\u{201D}\n\n— BloomHer")
                    .bloomSheet(detents: [.medium])
            }
        }
    }

    // MARK: - Current Affirmation

    private var currentAffirmation: AffirmationContent? {
        guard !viewModel.allAffirmations.isEmpty else { return nil }
        let idx = viewModel.affirmationIndex % viewModel.allAffirmations.count
        return viewModel.allAffirmations[idx]
    }

    // MARK: - Category Filter

    private var categoryFilterRow: some View {
        ScrollView(.horizontal) {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                ForEach(AffirmationCategory.allCases, id: \.self) { category in
                    BloomChip(
                        category.displayName,
                        icon: category.icon,
                        color: BloomHerTheme.Colors.primaryRose,
                        isSelected: currentAffirmation?.category == category,
                        action: {}
                    )
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.xxs)
        }
    }

    // MARK: - Main Affirmation Card

    @ViewBuilder
    private var affirmationCard: some View {
        if let affirmation = currentAffirmation {
            ZStack {
                // Background gradient
                affirmationGradient(for: affirmation)

                // Sparkle background particles
                AffirmationSparkleParticleView(
                    color: .white.opacity(0.6),
                    count: 12
                )
                .allowsHitTesting(false)

                // Card content
                VStack(spacing: BloomHerTheme.Spacing.xl) {
                    // Category badge
                    HStack {
                        categoryBadge(for: affirmation.category)
                        Spacer()
                    }

                    Spacer()

                    // Quote text
                    VStack(spacing: BloomHerTheme.Spacing.lg) {
                        Text("\u{201C}")
                            .font(BloomHerTheme.Typography.affirmationQuote)
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(y: BloomHerTheme.Spacing.xl)

                        Text(affirmation.text)
                            .font(BloomHerTheme.Typography.title2)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, BloomHerTheme.Spacing.sm)
                            .id(affirmation.id)
                            .transition(.asymmetric(
                                insertion: .move(edge: dragOffset < 0 ? .trailing : .leading).combined(with: .opacity),
                                removal: .move(edge: dragOffset < 0 ? .leading : .trailing).combined(with: .opacity)
                            ))
                    }

                    Spacer()

                    // Swipe hint
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(BloomIcons.chevronLeft)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                        Text("\(viewModel.affirmationIndex + 1) / \(viewModel.allAffirmations.count)")
                            .font(BloomHerTheme.Typography.footnote)
                        Image(BloomIcons.chevronRight)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                    }
                    .foregroundStyle(.white.opacity(0.65))
                }
                .padding(BloomHerTheme.Spacing.xl)

                // Heart particle overlay
                if showHeartParticles {
                    AffirmationHeartParticleView()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous))
            .shadow(
                color: phaseColor(for: affirmation).opacity(0.35),
                radius: 24, x: 0, y: 12
            )
            .offset(x: dragOffset)
            .opacity(cardOpacity)
            .gesture(swipeGesture)
            .animation(BloomHerTheme.Animation.standard, value: viewModel.affirmationIndex)
        }
    }

    // MARK: - Gradient

    private func affirmationGradient(for affirmation: AffirmationContent) -> some View {
        let base = phaseColor(for: affirmation)
        return LinearGradient(
            colors: [base, base.opacity(0.7), BloomHerTheme.Colors.accentLavender.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func phaseColor(for affirmation: AffirmationContent) -> Color {
        if let phase = affirmation.phase {
            return BloomHerTheme.Colors.phase(phase)
        }
        return BloomHerTheme.Colors.primaryRose
    }

    // MARK: - Category Badge

    private func categoryBadge(for category: AffirmationCategory) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.xxs) {
            Image(category.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
            Text(category.displayName)
                .font(BloomHerTheme.Typography.caption)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, BloomHerTheme.Spacing.sm)
        .padding(.vertical, BloomHerTheme.Spacing.xxs)
        .background(
            Capsule()
                .fill(.white.opacity(0.25))
        )
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        HStack(spacing: BloomHerTheme.Spacing.xxl) {
            // Previous
            Button {
                viewModel.previousAffirmation()
            } label: {
                Image(BloomIcons.chevronLeftCircle)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
            .buttonStyle(ScaleButtonStyle())

            Spacer()

            // Heart favourite
            Button {
                withAnimation(BloomHerTheme.Animation.quick) {
                    heartScale = 1.4
                }
                viewModel.toggleAffirmationFavourite()
                showHeartParticles = true
                withAnimation(BloomHerTheme.Animation.standard.delay(0.1)) {
                    heartScale = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showHeartParticles = false
                }
            } label: {
                Image(viewModel.isAffirmationFavourited ? BloomIcons.heartFilled : BloomIcons.heart)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    .scaleEffect(heartScale)
            }
            .buttonStyle(ScaleButtonStyle())

            Spacer()

            // Share
            Button {
                showShareSheet = true
            } label: {
                Image(BloomIcons.shareCircle)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
            .buttonStyle(ScaleButtonStyle())

            Spacer()

            // Next
            Button {
                viewModel.nextAffirmation()
            } label: {
                Image(BloomIcons.chevronRightCircle)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)
    }

    // MARK: - Swipe Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                dragOffset = value.translation.width * 0.3
                cardOpacity = Double(1 - abs(value.translation.width) / 500)
            }
            .onEnded { value in
                let threshold: CGFloat = 60
                if value.translation.width < -threshold {
                    viewModel.nextAffirmation()
                } else if value.translation.width > threshold {
                    viewModel.previousAffirmation()
                }
                withAnimation(BloomHerTheme.Animation.standard) {
                    dragOffset = 0
                    cardOpacity = 1
                }
            }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            KawaiiFace(expression: .happy, size: 80)
            Text("Blooming…")
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Local Heart Particles

private struct AffirmationHeartParticleView: View {
    @State private var particles: [(CGPoint, CGFloat, Double)] = []

    var body: some View {
        ZStack {
            ForEach(particles.indices, id: \.self) { i in
                let iconSize: CGFloat = particles[i].2 > 0.5 ? 18 : 10
                Image(BloomIcons.heartFilled)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .position(particles[i].0)
                    .opacity(particles[i].1)
            }
        }
        .onAppear { generateParticles() }
    }

    private func generateParticles() {
        particles = (0..<10).map { _ in
            let x = CGFloat.random(in: 40...340)
            let y = CGFloat.random(in: 100...400)
            let opacity = Double.random(in: 0.5...1.0)
            let rand = Double.random(in: 0...1)
            return (CGPoint(x: x, y: y), opacity, rand)
        }
    }
}

// MARK: - Local Sparkle Particles

private struct AffirmationSparkleParticleView: View {
    let color: Color
    let count: Int

    @State private var opacity: Double = 0.3

    var body: some View {
        Canvas { context, size in
            for i in 0..<count {
                let x = CGFloat(i) / CGFloat(count) * size.width
                    + sin(CGFloat(i) * 1.3) * size.width * 0.2
                let y = CGFloat(i % 4) / 4 * size.height
                    + cos(CGFloat(i) * 0.9) * size.height * 0.15
                let starSize = CGFloat.random(in: 4...10)
                var path = Path()
                path.addEllipse(in: CGRect(x: x - starSize/2, y: y - starSize/2, width: starSize, height: starSize))
                context.fill(path, with: .color(color.opacity(opacity)))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                opacity = 0.9
            }
        }
    }
}

// MARK: - Local Splash Particles

private struct AffirmationSplashParticleView: View {
    let color: Color
    let count: Int

    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 0.5

    var body: some View {
        Canvas { context, size in
            for i in 0..<count {
                let angle = CGFloat(i) / CGFloat(count) * 2 * .pi
                let radius: CGFloat = 30 * scale
                let x = size.width / 2 + cos(angle) * radius
                let y = size.height / 2 + sin(angle) * radius
                var path = Path()
                path.addEllipse(in: CGRect(x: x - 4, y: y - 4, width: 8, height: 8))
                context.fill(path, with: .color(color.opacity(opacity)))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                scale = 3.0
                opacity = 0
            }
        }
    }
}

// MARK: - ShareSheet

private struct ShareSheet: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview("Affirmation Card") {
    let deps = AppDependencies.preview()
    let vm = WellnessViewModel(dependencies: deps)
    vm.loadDailyContent()
    return NavigationStack {
        AffirmationCardView(viewModel: vm)
    }
    .environment(\.currentCyclePhase, .ovulation)
}
