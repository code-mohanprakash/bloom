//
//  FruitShapes.swift
//  BloomHer
//
//  Kawaii fruit illustrations for pregnancy week comparisons.
//  Each fruit is a SwiftUI View built from Circle, Ellipse, Path, Capsule, etc.
//  All fruits have:
//    • Gradient fills for depth
//    • A KawaiiFace overlay proportional to the fruit
//    • A `size` parameter for scalability
//    • A gentle idle bounce animation via PhaseAnimator
//

import SwiftUI

// MARK: - Idle bounce modifier

/// Applies a gentle perpetual bounce to any illustration view.
private struct IdleBounce: ViewModifier {
    func body(content: Content) -> some View {
        content
            .phaseAnimator([false, true]) { view, bounced in
                view.offset(y: bounced ? -5 : 0)
            } animation: { _ in
                .easeInOut(duration: 1.6).repeatForever(autoreverses: true)
            }
    }
}

private extension View {
    func idleBounce() -> some View {
        modifier(IdleBounce())
    }
}

// MARK: - PoppySeedShape

/// Tiny dark circle — week 4. Baby is ~1 mm.
struct PoppySeedShape: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "#4A3728"), Color(hex: "#2C1E10")],
                    center: .topLeading,
                    startRadius: size * 0.02,
                    endRadius: size * 0.35))
                .frame(width: size * 0.45, height: size * 0.45)
            // Shine
            Circle()
                .fill(Color.white.opacity(0.28))
                .frame(width: size * 0.12, height: size * 0.12)
                .offset(x: -size * 0.08, y: -size * 0.08)
            KawaiiFace(expression: .sleepy, size: size * 0.28)
        }
        .frame(width: size, height: size)
        .idleBounce()
    }
}

// MARK: - RaspberryShape

/// Cluster of small drupelets — week 8. Baby is ~1.6 cm.
struct RaspberryShape: View {
    let size: CGFloat

    private var drupeletColor: Color { Color(hex: "#C0395A") }
    private var drupeletHighlight: Color { Color(hex: "#E8607A") }
    private var drupeletRadius: CGFloat { size * 0.14 }

    // Positions for ~12 drupelets arranged in a raspberry silhouette
    private var drupeletOffsets: [(CGFloat, CGFloat)] {
        [
            (-0.16, -0.25), (0.0, -0.30), (0.16, -0.25),
            (-0.23, -0.07), (0.0, -0.10), (0.23, -0.07),
            (-0.18, 0.10),  (0.0,  0.08), (0.18, 0.10),
            (-0.10, 0.26),  (0.0,  0.28), (0.10, 0.26)
        ]
    }

    var body: some View {
        ZStack {
            ForEach(drupeletOffsets.indices, id: \.self) { i in
                let (dx, dy) = drupeletOffsets[i]
                ZStack {
                    Circle()
                        .fill(drupeletColor)
                        .frame(width: drupeletRadius * 2, height: drupeletRadius * 2)
                    // Each drupelet has a tiny shine dot
                    Circle()
                        .fill(drupeletHighlight.opacity(0.7))
                        .frame(width: drupeletRadius * 0.45,
                               height: drupeletRadius * 0.45)
                        .offset(x: -drupeletRadius * 0.22,
                                y: -drupeletRadius * 0.22)
                }
                .offset(x: dx * size, y: dy * size)
            }
            // Tiny green cap/leaves at top
            ForEach([-1, 0, 1], id: \.self) { i in
                Capsule()
                    .fill(Color(hex: "#5DBB63"))
                    .frame(width: size * 0.08, height: size * 0.18)
                    .rotationEffect(.degrees(Double(i) * 22))
                    .offset(y: -size * 0.38)
            }
            KawaiiFace(expression: .happy, size: size * 0.3)
                .offset(y: size * 0.02)
        }
        .frame(width: size, height: size)
        .idleBounce()
    }
}

// MARK: - LimeShape

/// Green circle with leaf — week 12. Baby is ~5 cm.
struct LimeShape: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Main lime body
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "#C5E85A"), Color(hex: "#7BC62D")],
                    center: .topLeading,
                    startRadius: size * 0.02,
                    endRadius: size * 0.45))
                .frame(width: size * 0.78, height: size * 0.78)
            // Shine
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: size * 0.22, height: size * 0.22)
                .offset(x: -size * 0.18, y: -size * 0.18)
            // Leaf
            LeafShape(curveBias: 0.1)
                .fill(Color(hex: "#4E9A2A"))
                .frame(width: size * 0.2, height: size * 0.32)
                .rotationEffect(.degrees(40))
                .offset(x: size * 0.3, y: -size * 0.3)
            // Small stem
            Capsule()
                .fill(Color(hex: "#5DBB63"))
                .frame(width: size * 0.045, height: size * 0.12)
                .offset(x: size * 0.27, y: -size * 0.38)
            KawaiiFace(expression: .happy, size: size * 0.35)
        }
        .frame(width: size, height: size)
        .idleBounce()
    }
}

// MARK: - AvocadoShape

/// Pear-shaped two-tone green — week 16. Baby is ~11.6 cm.
struct AvocadoShape: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Outer pear shape (dark green skin)
            AvocadoOuterShape()
                .fill(LinearGradient(
                    colors: [Color(hex: "#4A7C2F"), Color(hex: "#2D5016")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .frame(width: size * 0.65, height: size * 0.88)
            // Inner lighter flesh
            AvocadoOuterShape()
                .fill(LinearGradient(
                    colors: [Color(hex: "#C5E07A"), Color(hex: "#8DB84A")],
                    startPoint: .top,
                    endPoint: .bottom))
                .frame(width: size * 0.5, height: size * 0.72)
            // Pit
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "#8B5E3C"), Color(hex: "#5C3A1E")],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.12))
                .frame(width: size * 0.24, height: size * 0.24)
                .offset(y: size * 0.12)
            KawaiiFace(expression: .neutral, size: size * 0.3)
                .offset(y: -size * 0.08)
        }
        .frame(width: size, height: size)
        .idleBounce()
    }
}

private struct AvocadoOuterShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        // Narrow top (stem end), widens toward bottom
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.62),
            control1: CGPoint(x: w * 0.72, y: 0),
            control2: CGPoint(x: w, y: h * 0.35))
        path.addArc(
            center: CGPoint(x: w * 0.5, y: h * 0.62),
            radius: w * 0.5,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: true)
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: h * 0.35),
            control2: CGPoint(x: w * 0.28, y: 0))
        path.closeSubpath()
        return path
    }
}

// MARK: - BananaShape

/// Curved yellow capsule — week 20. Baby is ~25 cm.
struct BananaShape: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            BananaCurveShape()
                .fill(LinearGradient(
                    colors: [Color(hex: "#FFE566"), Color(hex: "#F4C300")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .frame(width: size * 0.82, height: size * 0.5)
            // Brown tip ends
            BananaTipShape(isLeft: true)
                .fill(Color(hex: "#8B6914"))
                .frame(width: size * 0.08, height: size * 0.12)
                .offset(x: -size * 0.36, y: -size * 0.06)
            BananaTipShape(isLeft: false)
                .fill(Color(hex: "#8B6914"))
                .frame(width: size * 0.08, height: size * 0.12)
                .offset(x: size * 0.36, y: size * 0.06)
            // Length lines
            ForEach([-1, 0, 1], id: \.self) { i in
                BananaCurveShape()
                    .stroke(Color(hex: "#D4A800").opacity(0.35), lineWidth: 1)
                    .frame(width: size * (0.82 - 0.08 * abs(Double(i))),
                           height: size * 0.5)
            }
            KawaiiFace(expression: .happy, size: size * 0.32)
        }
        .frame(width: size, height: size)
        .idleBounce()
    }
}

private struct BananaCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: 0, y: h * 0.6))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.4),
            control1: CGPoint(x: w * 0.25, y: -h * 0.1),
            control2: CGPoint(x: w * 0.75, y: -h * 0.1))
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.6),
            control1: CGPoint(x: w * 0.75, y: h * 1.1),
            control2: CGPoint(x: w * 0.25, y: h * 1.1))
        path.closeSubpath()
        return path
    }
}

private struct BananaTipShape: Shape {
    let isLeft: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if isLeft {
            path.move(to: CGPoint(x: rect.width, y: rect.height * 0.5))
            path.addQuadCurve(
                to: CGPoint(x: 0, y: 0),
                control: CGPoint(x: rect.width * 0.2, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: rect.height * 0.5),
                control: CGPoint(x: rect.width * 0.2, y: rect.height))
        } else {
            path.move(to: CGPoint(x: 0, y: rect.height * 0.5))
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: rect.height),
                control: CGPoint(x: rect.width * 0.8, y: rect.height))
            path.addQuadCurve(
                to: CGPoint(x: 0, y: rect.height * 0.5),
                control: CGPoint(x: rect.width * 0.8, y: 0))
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - CornShape

/// Tall yellow oval with kernel rows — week 24. Baby is ~30 cm.
struct CornShape: View {
    let size: CGFloat

    private let rows = 5
    private let cols = 4

    var body: some View {
        ZStack {
            // Husk base
            Capsule()
                .fill(LinearGradient(
                    colors: [Color(hex: "#F5E642"), Color(hex: "#D4B800")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .frame(width: size * 0.5, height: size * 0.82)
            // Kernel grid
            ForEach(0..<rows, id: \.self) { row in
                ForEach(0..<cols, id: \.self) { col in
                    RoundedRectangle(cornerRadius: size * 0.025)
                        .fill(Color(hex: "#F9D500").opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: size * 0.025)
                                .stroke(Color(hex: "#B89000").opacity(0.4), lineWidth: 0.5))
                        .frame(width: size * 0.1, height: size * 0.1)
                        .offset(
                            x: CGFloat(col - 1) * size * 0.115 + (row.isMultiple(of: 2) ? 0 : size * 0.058),
                            y: CGFloat(row - 2) * size * 0.14)
                }
            }
            // Green husk leaves at top
            ForEach([-1, 0, 1], id: \.self) { i in
                LeafShape(curveBias: CGFloat(i) * 0.2)
                    .fill(Color(hex: "#4E9A2A").opacity(0.85))
                    .frame(width: size * 0.24, height: size * 0.3)
                    .rotationEffect(.degrees(Double(i) * 30))
                    .offset(y: -size * 0.36)
            }
            KawaiiFace(expression: .happy, size: size * 0.28)
        }
        .frame(width: size, height: size)
        .idleBounce()
    }
}

// MARK: - EggplantShape

/// Purple curved oval with green cap — week 28. Baby is ~37 cm.
struct EggplantShape: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Body
            EggplantBodyShape()
                .fill(LinearGradient(
                    colors: [Color(hex: "#9B59B6"), Color(hex: "#5C2D7A")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .frame(width: size * 0.55, height: size * 0.8)
            // Shine stripe
            EggplantBodyShape()
                .fill(Color.white.opacity(0.18))
                .frame(width: size * 0.15, height: size * 0.58)
                .offset(x: -size * 0.12)
            // Green cap
            EggplantCapShape()
                .fill(Color(hex: "#4E9A2A"))
                .frame(width: size * 0.44, height: size * 0.22)
                .offset(y: -size * 0.36)
            // Stem
            Capsule()
                .fill(Color(hex: "#3D7A1E"))
                .frame(width: size * 0.05, height: size * 0.14)
                .offset(y: -size * 0.44)
            KawaiiFace(expression: .blush, size: size * 0.32)
                .offset(y: size * 0.06)
        }
        .frame(width: size, height: size)
        .idleBounce()
    }
}

private struct EggplantBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.55),
            control1: CGPoint(x: w * 0.78, y: 0),
            control2: CGPoint(x: w, y: h * 0.28))
        path.addArc(
            center: CGPoint(x: w * 0.5, y: h * 0.55),
            radius: w * 0.5,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: true)
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: h * 0.28),
            control2: CGPoint(x: w * 0.22, y: 0))
        path.closeSubpath()
        return path
    }
}

private struct EggplantCapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        // Three leaf-like sepals fanning out
        for i in 0..<3 {
            let angle = CGFloat(i - 1) * 0.6
            let tip = CGPoint(
                x: w * 0.5 + cos(angle - .pi/2) * w * 0.44,
                y: h * 0.5 + sin(angle - .pi/2) * h * 0.88)
            let base = CGPoint(x: w * 0.5, y: h * 0.9)
            path.move(to: base)
            path.addQuadCurve(
                to: tip,
                control: CGPoint(
                    x: base.x + cos(angle - .pi/2 - 0.4) * w * 0.3,
                    y: base.y + sin(angle - .pi/2 - 0.4) * h * 0.5))
            path.addQuadCurve(
                to: base,
                control: CGPoint(
                    x: base.x + cos(angle - .pi/2 + 0.4) * w * 0.3,
                    y: base.y + sin(angle - .pi/2 + 0.4) * h * 0.5))
        }
        return path
    }
}

// MARK: - CoconutShape

/// Brown circle with texture dots — week 32. Baby is ~42 cm.
struct CoconutShape: View {
    let size: CGFloat

    // Dot positions for coconut "eyes" and fibrous texture
    private let textureDots: [(CGFloat, CGFloat, CGFloat)] = [
        (-0.15, -0.15, 0.07),
        (0.08, -0.18, 0.05),
        (-0.22, 0.05, 0.04),
        (0.20, 0.08, 0.055),
        (-0.08, 0.22, 0.045),
        (0.14, 0.20, 0.04),
        (-0.28, -0.08, 0.035),
        (0.0, 0.0, 0.06)   // face position anchor (not drawn as dot)
    ]

    var body: some View {
        ZStack {
            // Main coconut body
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "#8B6340"), Color(hex: "#4A2E12")],
                    center: .topLeading,
                    startRadius: size * 0.04,
                    endRadius: size * 0.5))
                .frame(width: size * 0.82, height: size * 0.82)
            // Fibrous texture dots (darker brown)
            ForEach(textureDots.dropLast().indices, id: \.self) { i in
                let (dx, dy, r) = textureDots[i]
                Circle()
                    .fill(Color(hex: "#2C1A08").opacity(0.5))
                    .frame(width: size * r * 2, height: size * r * 2)
                    .offset(x: dx * size, y: dy * size)
            }
            // Three coconut "eyes" at the top
            ForEach([-0.08, 0.0, 0.08], id: \.self) { dx in
                Circle()
                    .fill(Color(hex: "#1A0C04"))
                    .frame(width: size * 0.06, height: size * 0.06)
                    .offset(x: dx * size, y: -size * 0.28)
            }
            KawaiiFace(expression: .neutral, size: size * 0.34)
                .offset(y: size * 0.06)
        }
        .frame(width: size, height: size)
        .idleBounce()
    }
}

// MARK: - MelonShape

/// Large green circle with stripes — week 36. Baby is ~47 cm.
struct MelonShape: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Outer green rind
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "#78C850"), Color(hex: "#2D8A3E")],
                    center: .topLeading,
                    startRadius: size * 0.05,
                    endRadius: size * 0.5))
                .frame(width: size * 0.9, height: size * 0.9)
            // Stripe arcs
            ForEach(0..<6, id: \.self) { i in
                MelonStripeShape(index: i, total: 6)
                    .stroke(Color(hex: "#1E6B2E").opacity(0.5), lineWidth: size * 0.04)
                    .frame(width: size * 0.9, height: size * 0.9)
            }
            // Shine
            Circle()
                .fill(Color.white.opacity(0.22))
                .frame(width: size * 0.28, height: size * 0.28)
                .offset(x: -size * 0.2, y: -size * 0.2)
            // Tiny stem
            Capsule()
                .fill(Color(hex: "#5DBB63"))
                .frame(width: size * 0.06, height: size * 0.1)
                .offset(y: -size * 0.44)
            KawaiiFace(expression: .happy, size: size * 0.34)
        }
        .frame(width: size, height: size)
        .idleBounce()
    }
}

private struct MelonStripeShape: Shape {
    let index: Int
    let total: Int

    func path(in rect: CGRect) -> Path {
        let angle = CGFloat(index) / CGFloat(total) * .pi * 2
        let cx = rect.midX, cy = rect.midY
        let r = min(rect.width, rect.height) / 2
        var path = Path()
        path.move(to: CGPoint(x: cx, y: cy))
        path.addLine(to: CGPoint(
            x: cx + cos(angle) * r,
            y: cy + sin(angle) * r))
        return path
    }
}

// MARK: - WatermelonShape

/// Oval with green outside, pink inside, seed dots — week 40. Baby is ~51 cm.
struct WatermelonShape: View {
    let size: CGFloat

    private let seedPositions: [(CGFloat, CGFloat, CGFloat)] = [
        (-0.15, 0.08, -20),
        (0.12,  0.14,  15),
        (-0.04, 0.20,   5),
        ( 0.22, 0.02, -10),
        (-0.25, 0.16,  25),
        ( 0.05, -0.02, 30)
    ]

    var body: some View {
        ZStack {
            // Outer green rind oval
            Ellipse()
                .fill(Color(hex: "#2D8A3E"))
                .frame(width: size * 0.92, height: size * 0.74)
            // White inner rind strip
            Ellipse()
                .fill(Color(hex: "#E8F5E8"))
                .frame(width: size * 0.84, height: size * 0.66)
            // Pink flesh
            Ellipse()
                .fill(LinearGradient(
                    colors: [Color(hex: "#FF8FA3"), Color(hex: "#E8526A")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .frame(width: size * 0.76, height: size * 0.58)
            // Green stripes on rind
            ForEach(0..<4, id: \.self) { i in
                Ellipse()
                    .stroke(Color(hex: "#1E6B2E").opacity(0.55), lineWidth: size * 0.025)
                    .frame(
                        width: size * (0.92 - CGFloat(i) * 0.06),
                        height: size * (0.74 - CGFloat(i) * 0.048))
            }
            // Seeds
            ForEach(seedPositions.indices, id: \.self) { i in
                let (dx, dy, rot) = seedPositions[i]
                Ellipse()
                    .fill(Color(hex: "#1A0C04"))
                    .frame(width: size * 0.055, height: size * 0.038)
                    .rotationEffect(.degrees(rot))
                    .offset(x: dx * size, y: dy * size)
            }
            KawaiiFace(expression: .excited, size: size * 0.32)
                .offset(y: -size * 0.04)
        }
        .frame(width: size, height: size)
        .idleBounce()
    }
}

// MARK: - Preview

#Preview("Fruit Shapes") {
    ScrollView {
        VStack(spacing: 8) {
            Text("Pregnancy Fruits")
                .font(.headline.rounded())
                .padding(.top)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                Group {
                    fruitPreview(PoppySeedShape(size: 80), "Poppy Seed\nWk 4")
                    fruitPreview(RaspberryShape(size: 80), "Raspberry\nWk 8")
                    fruitPreview(LimeShape(size: 80), "Lime\nWk 12")
                    fruitPreview(AvocadoShape(size: 80), "Avocado\nWk 16")
                    fruitPreview(BananaShape(size: 80), "Banana\nWk 20")
                    fruitPreview(CornShape(size: 80), "Corn\nWk 24")
                }
                Group {
                    fruitPreview(EggplantShape(size: 80), "Eggplant\nWk 28")
                    fruitPreview(CoconutShape(size: 80), "Coconut\nWk 32")
                    fruitPreview(MelonShape(size: 80), "Melon\nWk 36")
                    fruitPreview(WatermelonShape(size: 80), "Watermelon\nWk 40")
                }
            }
            .padding()
        }
    }
    .background(Color(hex: "#FFF8F5"))
}

@ViewBuilder
private func fruitPreview<V: View>(_ view: V, _ label: String) -> some View {
    VStack(spacing: 4) {
        view
        Text(label)
            .font(.caption2.rounded())
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
    }
}
