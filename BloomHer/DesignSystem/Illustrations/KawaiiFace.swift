//
//  KawaiiFace.swift
//  BloomHer
//
//  Core face component that sits on every kawaii illustration.
//  Built entirely with SwiftUI primitives — no image assets.
//
//  All measurements are proportional to `size` so the face scales
//  perfectly from tiny (24 pt) to large (200 pt) contexts.
//

import SwiftUI

// MARK: - KawaiiFace

/// A kawaii-style face that can be placed on any illustration shape.
///
/// The face supports seven expressions that change eye and mouth geometry:
///
/// | Expression | Eyes              | Mouth           |
/// |------------|-------------------|-----------------|
/// | happy      | upward arcs (^_^) | smile curve     |
/// | sleepy     | horizontal bars   | small 'o'       |
/// | excited    | large circles     | wide 'D' shape  |
/// | sad        | downward curves   | frown curve     |
/// | surprised  | large circles     | small 'o'       |
/// | neutral    | small dots        | short line      |
/// | blush      | happy arcs + pink | cat 'w' mouth   |
///
struct KawaiiFace: View {

    // MARK: - Expression

    enum Expression: String, CaseIterable, Identifiable {
        case happy, sleepy, excited, sad, surprised, neutral, blush
        var id: String { rawValue }
    }

    // MARK: - Properties

    let expression: Expression
    /// Diameter of the face area in points.
    let size: CGFloat

    // MARK: - Derived layout constants

    private var eyeY: CGFloat     { -size * 0.1 }
    private var eyeSpacing: CGFloat { size * 0.22 }
    private var mouthY: CGFloat   { size * 0.12 }

    // MARK: - Body

    var body: some View {
        ZStack {
            eyes
            mouth
            if showsBlush {
                blushMarks
            }
            if showsSparkles {
                sparkles
            }
        }
        .frame(width: size, height: size)
    }

    // MARK: - Eye layer

    @ViewBuilder
    private var eyes: some View {
        switch expression {
        case .happy, .blush:
            // ^_^ upward arc eyes
            HStack(spacing: eyeSpacing) {
                ArcEyeShape(isUpward: true)
                    .stroke(eyeColor, style: StrokeStyle(lineWidth: eyeStroke, lineCap: .round))
                    .frame(width: eyeWidth, height: eyeHeight)
                ArcEyeShape(isUpward: true)
                    .stroke(eyeColor, style: StrokeStyle(lineWidth: eyeStroke, lineCap: .round))
                    .frame(width: eyeWidth, height: eyeHeight)
            }
            .offset(y: eyeY)

        case .sleepy:
            // — — horizontal bar eyes
            HStack(spacing: eyeSpacing) {
                Capsule()
                    .fill(eyeColor)
                    .frame(width: eyeWidth, height: size * 0.04)
                Capsule()
                    .fill(eyeColor)
                    .frame(width: eyeWidth, height: size * 0.04)
            }
            .offset(y: eyeY)

        case .excited, .surprised:
            // O O large circle eyes with highlight
            HStack(spacing: eyeSpacing * 0.75) {
                largeEyeCircle
                largeEyeCircle
            }
            .offset(y: eyeY)

        case .sad:
            // downturned arc eyes
            HStack(spacing: eyeSpacing) {
                ArcEyeShape(isUpward: false)
                    .stroke(eyeColor, style: StrokeStyle(lineWidth: eyeStroke, lineCap: .round))
                    .frame(width: eyeWidth, height: eyeHeight)
                ArcEyeShape(isUpward: false)
                    .stroke(eyeColor, style: StrokeStyle(lineWidth: eyeStroke, lineCap: .round))
                    .frame(width: eyeWidth, height: eyeHeight)
            }
            .offset(y: eyeY)

        case .neutral:
            // · · small dot eyes
            HStack(spacing: eyeSpacing) {
                Circle()
                    .fill(eyeColor)
                    .frame(width: size * 0.07, height: size * 0.07)
                Circle()
                    .fill(eyeColor)
                    .frame(width: size * 0.07, height: size * 0.07)
            }
            .offset(y: eyeY)
        }
    }

    private var largeEyeCircle: some View {
        ZStack {
            Circle()
                .fill(eyeColor)
                .frame(width: size * 0.16, height: size * 0.16)
            // Shine highlight
            Circle()
                .fill(Color.white.opacity(0.85))
                .frame(width: size * 0.06, height: size * 0.06)
                .offset(x: size * 0.04, y: -size * 0.04)
        }
    }

    // MARK: - Mouth layer

    @ViewBuilder
    private var mouth: some View {
        switch expression {
        case .happy:
            SmileMouthShape(isSmile: true)
                .stroke(eyeColor, style: StrokeStyle(lineWidth: eyeStroke, lineCap: .round))
                .frame(width: mouthWidth, height: mouthHeight)
                .offset(y: mouthY)

        case .sleepy:
            Circle()
                .fill(eyeColor.opacity(0.7))
                .frame(width: size * 0.07, height: size * 0.07)
                .offset(y: mouthY)

        case .excited:
            // Wide open 'D' shape — flat top, curved bottom
            ExcitedMouthShape()
                .fill(eyeColor.opacity(0.85))
                .frame(width: mouthWidth * 1.2, height: mouthHeight * 1.4)
                .offset(y: mouthY)

        case .sad:
            SmileMouthShape(isSmile: false)
                .stroke(eyeColor, style: StrokeStyle(lineWidth: eyeStroke, lineCap: .round))
                .frame(width: mouthWidth, height: mouthHeight)
                .offset(y: mouthY)

        case .surprised:
            Circle()
                .fill(eyeColor.opacity(0.8))
                .frame(width: size * 0.09, height: size * 0.09)
                .offset(y: mouthY)

        case .neutral:
            Capsule()
                .fill(eyeColor)
                .frame(width: mouthWidth * 0.7, height: size * 0.03)
                .offset(y: mouthY)

        case .blush:
            // Cat-like 'w' mouth
            CatMouthShape()
                .stroke(eyeColor, style: StrokeStyle(lineWidth: eyeStroke * 0.85, lineCap: .round))
                .frame(width: mouthWidth, height: mouthHeight)
                .offset(y: mouthY)
        }
    }

    // MARK: - Blush marks

    private var showsBlush: Bool {
        expression == .blush || expression == .excited
    }

    private var blushMarks: some View {
        HStack(spacing: size * 0.55) {
            Ellipse()
                .fill(Color(hex: "#F4A0B5").opacity(0.55))
                .frame(width: size * 0.18, height: size * 0.1)
            Ellipse()
                .fill(Color(hex: "#F4A0B5").opacity(0.55))
                .frame(width: size * 0.18, height: size * 0.1)
        }
        .offset(y: mouthY * 0.3)
    }

    // MARK: - Sparkles (excited expression)

    private var showsSparkles: Bool { expression == .excited }

    private var sparkles: some View {
        ZStack {
            TinySparkle()
                .fill(BloomColors.accentPeach)
                .frame(width: size * 0.14, height: size * 0.14)
                .offset(x: -size * 0.38, y: -size * 0.28)
            TinySparkle()
                .fill(BloomColors.accentPeach.opacity(0.75))
                .frame(width: size * 0.09, height: size * 0.09)
                .offset(x: size * 0.38, y: -size * 0.3)
        }
    }

    // MARK: - Sizing helpers

    private var eyeWidth: CGFloat  { size * 0.14 }
    private var eyeHeight: CGFloat { size * 0.08 }
    private var eyeStroke: CGFloat { max(1.5, size * 0.045) }
    private var mouthWidth: CGFloat  { size * 0.3 }
    private var mouthHeight: CGFloat { size * 0.1 }
    private var eyeColor: Color { Color(hex: "#3D2C2E") }
}

// MARK: - Eye Shapes

/// Arc shape used for happy (^) and sad (v) eyes.
private struct ArcEyeShape: Shape {
    let isUpward: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if isUpward {
            // Arc opening downward visually = upward-looking arc (^)
            path.move(to: CGPoint(x: 0, y: rect.height))
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: rect.height),
                control: CGPoint(x: rect.midX, y: 0))
        } else {
            // Arc opening upward visually = sad arc (v)
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: 0),
                control: CGPoint(x: rect.midX, y: rect.height))
        }
        return path
    }
}

// MARK: - Mouth Shapes

/// Smile or frown mouth curve.
private struct SmileMouthShape: Shape {
    let isSmile: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if isSmile {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: 0),
                control: CGPoint(x: rect.midX, y: rect.height))
        } else {
            path.move(to: CGPoint(x: 0, y: rect.height))
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: rect.height),
                control: CGPoint(x: rect.midX, y: 0))
        }
        return path
    }
}

/// Wide 'D' open mouth for excited expression.
private struct ExcitedMouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Cat-like 'w' mouth for blush expression.
private struct CatMouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let bot  = rect.maxY
        // Left dip
        path.move(to: CGPoint(x: 0, y: rect.height * 0.3))
        path.addQuadCurve(
            to: CGPoint(x: midX * 0.7, y: bot),
            control: CGPoint(x: rect.width * 0.18, y: bot))
        // Center rise
        path.addQuadCurve(
            to: CGPoint(x: midX, y: rect.height * 0.5),
            control: CGPoint(x: midX * 0.88, y: bot * 0.6))
        // Right dip
        path.addQuadCurve(
            to: CGPoint(x: midX + midX * 0.3, y: bot),
            control: CGPoint(x: midX * 1.12, y: bot * 0.6))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.3),
            control: CGPoint(x: rect.width * 0.82, y: bot))
        return path
    }
}

// MARK: - Tiny Sparkle Shape

/// Small 4-pointed star used for sparkle accents near excited eyes.
struct TinySparkle: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX, cy = rect.midY
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.35
        var path = Path()
        for i in 0..<4 {
            let outerAngle = CGFloat(i) * .pi / 2 - .pi / 4
            let innerAngle = outerAngle + .pi / 4
            let op = CGPoint(x: cx + cos(outerAngle) * outer,
                             y: cy + sin(outerAngle) * outer)
            let ip = CGPoint(x: cx + cos(innerAngle) * inner,
                             y: cy + sin(innerAngle) * inner)
            if i == 0 { path.move(to: op) } else { path.addLine(to: op) }
            path.addLine(to: ip)
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview("All Expressions") {
    VStack(spacing: 20) {
        Text("KawaiiFace Expressions")
            .font(.headline.rounded())
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
            ForEach(KawaiiFace.Expression.allCases) { expr in
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(BloomColors.accentPeach.opacity(0.4))
                            .frame(width: 72, height: 72)
                        KawaiiFace(expression: expr, size: 52)
                    }
                    Text(expr.rawValue)
                        .font(.caption2.rounded())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
    .padding()
    .background(Color(hex: "#FFF8F5"))
}
