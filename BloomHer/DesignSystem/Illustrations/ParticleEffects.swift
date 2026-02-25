//
//  ParticleEffects.swift
//  BloomHer
//
//  Canvas-based particle systems for ambient animations.
//  Each system uses TimelineView + Canvas for smooth 60fps rendering
//  with no UIKit involvement.
//
//  Systems:
//    SplashParticleView  — water splash rings expand outward and fade
//    SparkleParticleView — 4-pointed stars twinkle around a center point
//    HeartParticleView   — small hearts float upward and fade
//    PetalFallView       — oval petals drift downward gently
//

import SwiftUI

// MARK: - Particle Model

/// Internal data for a single particle instance.
private struct Particle {
    var x: CGFloat        // normalized 0-1 within canvas width
    var y: CGFloat        // normalized 0-1 within canvas height
    var angle: CGFloat    // radians — travel direction
    var speed: CGFloat    // movement per second (normalized)
    var scale: CGFloat    // current rendered scale
    var opacity: CGFloat  // current opacity
    var life: CGFloat     // normalized 0-1 lifetime progress
    var lifespan: CGFloat // total seconds this particle lives
    var birthTime: TimeInterval
    var rotation: CGFloat // shape rotation in radians
}

// MARK: - SplashParticleView

/// Water splash: expanding translucent circles that fade out.
///
/// Use this as a transient overlay when water is added/consumed.
///
/// ```swift
/// SplashParticleView(color: BloomColors.waterBlueTint, count: 8)
///     .frame(width: 100, height: 100)
///     .allowsHitTesting(false)
/// ```
struct SplashParticleView: View {

    var color: Color = BloomColors.waterBlueTint
    var count: Int = 10
    /// Duration each droplet lives in seconds.
    var duration: Double = 0.9

    @State private var particles: [Particle] = []
    @State private var startTime: TimeInterval = 0

    var body: some View {
        TimelineView(.animation) { context in
            Canvas { canvas, size in
                let now = context.date.timeIntervalSinceReferenceDate
                for particle in particles {
                    let age = now - particle.birthTime
                    let t = min(age / particle.lifespan, 1.0)
                    guard t < 1.0 else { continue }

                    let eased = sin(t * .pi) // rises then falls
                    let radius = size.width * 0.04 + size.width * 0.18 * t
                    let cx = size.width  * particle.x + cos(particle.angle) * size.width * 0.35 * t
                    let cy = size.height * particle.y + sin(particle.angle) * size.height * 0.35 * t
                    let opacity = eased * 0.7

                    canvas.stroke(
                        Path(ellipseIn: CGRect(
                            x: cx - radius,
                            y: cy - radius,
                            width: radius * 2,
                            height: radius * 2)),
                        with: .color(color.opacity(opacity)),
                        lineWidth: 2.0)
                }
            }
        }
        .onAppear {
            startTime = Date.timeIntervalSinceReferenceDate
            spawnParticles()
        }
    }

    private func spawnParticles() {
        let now = Date.timeIntervalSinceReferenceDate
        particles = (0..<count).map { i in
            let angle = CGFloat(i) / CGFloat(count) * .pi * 2
            return Particle(
                x: 0.5, y: 0.5,
                angle: angle,
                speed: 0.3 + CGFloat.random(in: 0...0.15),
                scale: 0.3,
                opacity: 1.0,
                life: 0,
                lifespan: duration + Double.random(in: -0.1...0.2),
                birthTime: now + Double.random(in: 0...0.12),
                rotation: 0)
        }
    }
}

// MARK: - SparkleParticleView

/// 4-pointed sparkle stars that appear and twinkle around a region.
///
/// Ideal as an ambient overlay during the ovulation phase or on
/// 100% completion states.
///
/// ```swift
/// SparkleParticleView(color: BloomColors.accentPeach, count: 12)
///     .frame(width: 200, height: 200)
///     .allowsHitTesting(false)
/// ```
struct SparkleParticleView: View {

    var color: Color = BloomColors.accentPeach
    var count: Int = 12
    var duration: Double = 1.8

    @State private var particles: [Particle] = []

    var body: some View {
        TimelineView(.animation) { context in
            Canvas { canvas, size in
                let now = context.date.timeIntervalSinceReferenceDate
                for particle in particles {
                    let age = now - particle.birthTime
                    guard age > 0 else { continue }
                    let t = min(age / particle.lifespan, 1.0)
                    guard t < 1.0 else { continue }

                    // Scale up fast, then hold, then fade out
                    let scaleCurve: CGFloat = t < 0.3
                        ? t / 0.3
                        : 1.0 - (t - 0.3) / 0.7
                    let opacity = scaleCurve * 0.9
                    let r = size.width * 0.06 * scaleCurve * particle.scale

                    let cx = size.width  * particle.x
                    let cy = size.height * particle.y
                    let rot = particle.rotation + t * .pi

                    // Draw 4-pointed star via lines
                    canvas.withCGContext { ctx in
                        ctx.setStrokeColor(UIColor(color.opacity(opacity)).cgColor)
                        ctx.setLineWidth(max(1.0, r * 0.3))
                        ctx.setLineCap(.round)
                        for arm in 0..<4 {
                            let a = rot + CGFloat(arm) * .pi / 2
                            let inner = r * 0.22
                            let outer = r
                            ctx.move(to: CGPoint(
                                x: cx + cos(a) * inner,
                                y: cy + sin(a) * inner))
                            ctx.addLine(to: CGPoint(
                                x: cx + cos(a) * outer,
                                y: cy + sin(a) * outer))
                        }
                        ctx.strokePath()
                    }
                }
            }
        }
        .onAppear { spawnParticles(canvasSize: CGSize(width: 200, height: 200)) }
    }

    private func spawnParticles(canvasSize: CGSize) {
        let now = Date.timeIntervalSinceReferenceDate
        particles = (0..<count).map { _ in
            Particle(
                x: CGFloat.random(in: 0.05...0.95),
                y: CGFloat.random(in: 0.05...0.95),
                angle: 0,
                speed: 0,
                scale: CGFloat.random(in: 0.6...1.4),
                opacity: 0,
                life: 0,
                lifespan: duration * Double.random(in: 0.7...1.3),
                birthTime: now + Double.random(in: 0...(duration * 0.8)),
                rotation: CGFloat.random(in: 0...(.pi / 4)))
        }
    }
}

// MARK: - HeartParticleView

/// Small hearts that float upward and fade out.
///
/// Used on love/affirmation interactions and the heart object illustration.
///
/// ```swift
/// HeartParticleView(color: BloomColors.primaryRose, count: 6)
///     .frame(width: 120, height: 200)
///     .allowsHitTesting(false)
/// ```
struct HeartParticleView: View {

    var color: Color = BloomColors.primaryRose
    var count: Int = 8
    var duration: Double = 2.2

    @State private var particles: [Particle] = []

    var body: some View {
        TimelineView(.animation) { context in
            Canvas { canvas, size in
                let now = context.date.timeIntervalSinceReferenceDate
                for particle in particles {
                    let age = now - particle.birthTime
                    guard age > 0 else { continue }
                    let t = min(age / particle.lifespan, 1.0)
                    guard t < 1.0 else { continue }

                    // Rise upward with slight side drift
                    let currentX = size.width * particle.x + sin(t * .pi * 2) * size.width * 0.05
                    let currentY = size.height * particle.y - t * size.height * 0.7
                    let opacity = t < 0.1 ? t / 0.1 : 1.0 - (t - 0.1) / 0.9
                    let r = size.width * 0.06 * particle.scale

                    canvas.withCGContext { ctx in
                        ctx.setAlpha(opacity * 0.85)
                        ctx.translateBy(x: currentX, y: currentY)
                        ctx.rotate(by: particle.rotation)
                        // Tiny heart path
                        let path = UIBezierPath()
                        path.move(to: CGPoint(x: 0, y: r * 0.3))
                        path.addCurve(
                            to: CGPoint(x: -r, y: -r * 0.4),
                            controlPoint1: CGPoint(x: -r * 0.4, y: 0),
                            controlPoint2: CGPoint(x: -r, y: -r * 0.1))
                        path.addCurve(
                            to: CGPoint(x: 0, y: -r * 0.1),
                            controlPoint1: CGPoint(x: -r, y: -r),
                            controlPoint2: CGPoint(x: -r * 0.3, y: -r * 0.8))
                        path.addCurve(
                            to: CGPoint(x: r, y: -r * 0.4),
                            controlPoint1: CGPoint(x: r * 0.3, y: -r * 0.8),
                            controlPoint2: CGPoint(x: r, y: -r))
                        path.addCurve(
                            to: CGPoint(x: 0, y: r * 0.3),
                            controlPoint1: CGPoint(x: r, y: -r * 0.1),
                            controlPoint2: CGPoint(x: r * 0.4, y: 0))
                        path.close()
                        ctx.addPath(path.cgPath)
                        ctx.setFillColor(UIColor(color).cgColor)
                        ctx.fillPath()
                    }
                }
            }
        }
        .onAppear { spawnParticles() }
    }

    private func spawnParticles() {
        let now = Date.timeIntervalSinceReferenceDate
        particles = (0..<count).map { _ in
            Particle(
                x: CGFloat.random(in: 0.2...0.8),
                y: CGFloat.random(in: 0.7...0.95),
                angle: 0,
                speed: 0,
                scale: CGFloat.random(in: 0.5...1.2),
                opacity: 0,
                life: 0,
                lifespan: duration * Double.random(in: 0.7...1.3),
                birthTime: now + Double.random(in: 0...(duration * 0.6)),
                rotation: CGFloat.random(in: -0.3...0.3))
        }
    }
}

// MARK: - PetalFallView

/// Oval flower petals that drift downward and sideways, gently rotating.
///
/// Used during the luteal phase of `BloomFlowerGrowth` and as ambient
/// decoration on full-flower illustrations.
///
/// ```swift
/// PetalFallView(petalColor: BloomColors.primaryRose, count: 10)
///     .frame(width: 300, height: 400)
///     .allowsHitTesting(false)
/// ```
struct PetalFallView: View {

    var petalColor: Color = BloomColors.primaryRose
    var count: Int = 12
    var duration: Double = 3.5

    @State private var particles: [Particle] = []

    var body: some View {
        TimelineView(.animation) { context in
            Canvas { canvas, size in
                let now = context.date.timeIntervalSinceReferenceDate
                for particle in particles {
                    let age = now - particle.birthTime
                    guard age > 0 else { continue }
                    let t = min(age / particle.lifespan, 1.0)
                    guard t < 1.0 else { continue }

                    // Fall downward with sinusoidal drift
                    let drift = sin(t * .pi * 1.5 + particle.x * 4) * size.width * 0.12
                    let currentX = size.width * particle.x + drift
                    let currentY = -size.height * 0.08 + t * size.height * 1.15

                    // Fade in briefly, hold, fade out at end
                    let opacity: CGFloat = t < 0.08
                        ? t / 0.08
                        : t > 0.85 ? (1.0 - t) / 0.15 : 0.75

                    let pw = size.width * 0.055 * particle.scale
                    let ph = size.height * 0.04 * particle.scale
                    let rot = particle.rotation + t * .pi * 2.5

                    canvas.withCGContext { ctx in
                        ctx.setAlpha(opacity)
                        ctx.translateBy(x: currentX, y: currentY)
                        ctx.rotate(by: rot)
                        let rect = CGRect(x: -pw/2, y: -ph/2, width: pw, height: ph)
                        let ovalPath = UIBezierPath(ovalIn: rect)
                        ctx.addPath(ovalPath.cgPath)
                        ctx.setFillColor(UIColor(petalColor).cgColor)
                        ctx.fillPath()
                    }
                }
            }
        }
        .onAppear { spawnParticles() }
    }

    private func spawnParticles() {
        let now = Date.timeIntervalSinceReferenceDate
        particles = (0..<count).map { _ in
            Particle(
                x: CGFloat.random(in: 0.0...1.0),
                y: 0,
                angle: 0,
                speed: 0,
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: 0,
                life: 0,
                lifespan: duration * Double.random(in: 0.7...1.3),
                birthTime: now + Double.random(in: 0...(duration * 0.9)),
                rotation: CGFloat.random(in: 0...(.pi * 2)))
        }
    }
}

// MARK: - Preview

#Preview("Particle Effects") {
    ZStack {
        Color(hex: "#FFF8F5").ignoresSafeArea()
        VStack(spacing: 20) {
            Text("Particle Effects").font(.headline.rounded())

            HStack(spacing: 16) {
                VStack(spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(BloomColors.waterBlueTint.opacity(0.2))
                        SplashParticleView(color: Color(hex: "#5BBCEF"), count: 8)
                    }
                    .frame(width: 90, height: 90)
                    Text("Splash").font(.caption2.rounded())
                }
                VStack(spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(BloomColors.accentPeach.opacity(0.2))
                        SparkleParticleView(color: BloomColors.accentPeach, count: 10)
                    }
                    .frame(width: 90, height: 90)
                    Text("Sparkle").font(.caption2.rounded())
                }
                VStack(spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(BloomColors.primaryRose.opacity(0.2))
                        HeartParticleView(color: BloomColors.primaryRose, count: 6)
                    }
                    .frame(width: 90, height: 90)
                    Text("Hearts").font(.caption2.rounded())
                }
            }

            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(BloomColors.primaryRose.opacity(0.1))
                    PetalFallView(petalColor: BloomColors.primaryRose, count: 14)
                }
                .frame(width: 280, height: 120)
                Text("Petal Fall").font(.caption2.rounded())
            }
        }
        .padding()
    }
}
