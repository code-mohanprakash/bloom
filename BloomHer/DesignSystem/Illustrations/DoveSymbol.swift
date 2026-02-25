//
//  DoveSymbol.swift
//  BloomHer
//
//  An abstract, elegant dove silhouette rendered as a SwiftUI Shape.
//  The form is clean and symbolic — a peace dove in ascent — composed
//  of a single Bezier path tracing the body, a swept wing arc, and a
//  small head/beak suggestion.  Suitable for both `.fill()` and
//  `.stroke()` rendering modes.
//
//  Usage:
//      DoveSymbol()
//          .fill(BloomColors.primaryRose)
//          .frame(width: 120, height: 120)
//
//      DoveSymbolView(size: 160, style: .gradient)
//

import SwiftUI

// MARK: - DoveSymbol Shape

/// A minimal, abstract dove silhouette drawn with cubic Bezier curves.
///
/// The dove faces right and is angled slightly upward to convey ascent
/// and hope.  The path is normalised to a 100×100 unit square and
/// scales automatically when placed inside any `frame`.
///
/// Anatomy of the path:
///   1. Body — a fluid teardrop-like curve forming the torso and tail
///   2. Wing — a single broad upswept arc rising from the shoulder
///   3. Head — a small circular bump at the front of the body
///   4. Beak — a tiny triangular projection pointing right
struct DoveSymbol: Shape {

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        // Scale helpers — the design is authored in a 100×100 unit space.
        func x(_ v: CGFloat) -> CGFloat { rect.minX + v / 100 * w }
        func y(_ v: CGFloat) -> CGFloat { rect.minY + v / 100 * h }
        func p(_ px: CGFloat, _ py: CGFloat) -> CGPoint { CGPoint(x: x(px), y: y(py)) }

        var path = Path()

        // ── Body ────────────────────────────────────────────────────────
        // Starts at the tail tip (left-centre), sweeps forward to the
        // breast, curves up to the neck, and returns along the back.

        // Tail tip
        path.move(to: p(8, 58))

        // Lower belly curve toward breast
        path.addCurve(
            to: p(62, 62),
            control1: p(20, 72),
            control2: p(46, 70)
        )

        // Breast forward and slightly up to beak base
        path.addCurve(
            to: p(88, 46),
            control1: p(74, 62),
            control2: p(86, 56)
        )

        // Beak — sharp forward projection
        path.addLine(to: p(100, 42))
        path.addLine(to: p(88, 40))

        // Throat back to neck
        path.addCurve(
            to: p(68, 38),
            control1: p(84, 36),
            control2: p(76, 35)
        )

        // Head bump (top of head arc)
        path.addCurve(
            to: p(56, 30),
            control1: p(62, 36),
            control2: p(56, 33)
        )

        // Back of head continuing along the back-line
        path.addCurve(
            to: p(28, 38),
            control1: p(56, 26),
            control2: p(40, 30)
        )

        // Back sweep down toward tail
        path.addCurve(
            to: p(8, 58),
            control1: p(16, 43),
            control2: p(8, 50)
        )

        path.closeSubpath()

        // ── Wing ────────────────────────────────────────────────────────
        // A single broad upswept crescent rising from the shoulder area,
        // returning below its start to give depth to the feather arc.

        // Wing root on the back (shoulder)
        path.move(to: p(32, 37))

        // Upper leading edge — sweeps up and right
        path.addCurve(
            to: p(80, 16),
            control1: p(44, 18),
            control2: p(64, 10)
        )

        // Wing tip flick (right-most point of the wing)
        path.addCurve(
            to: p(90, 22),
            control1: p(86, 14),
            control2: p(90, 17)
        )

        // Trailing edge — sweeps back down to shoulder
        path.addCurve(
            to: p(32, 37),
            control1: p(70, 30),
            control2: p(50, 36)
        )

        path.closeSubpath()

        // ── Eye (small filled circle) ────────────────────────────────────
        let eyeCX = x(72)
        let eyeCY = y(40)
        let eyeR  = min(w, h) * 0.028
        path.addEllipse(in: CGRect(
            x: eyeCX - eyeR,
            y: eyeCY - eyeR,
            width: eyeR * 2,
            height: eyeR * 2
        ))

        return path
    }
}

// MARK: - DoveSymbolView

/// A ready-to-use view wrapping `DoveSymbol` with three rendering styles.
///
/// - `.gradient`  — rose-to-peach linear gradient fill (default, best for hero use)
/// - `.filled`    — solid `primaryRose` fill
/// - `.outlined`  — stroke-only rendering in `primaryRose`
struct DoveSymbolView: View {

    // MARK: Configuration

    var size: CGFloat   = 120
    var style: DoveStyle = .gradient

    enum DoveStyle {
        case gradient, outlined, filled
    }

    // MARK: Body

    var body: some View {
        switch style {
        case .gradient:
            gradientDove
        case .filled:
            filledDove
        case .outlined:
            outlinedDove
        }
    }

    // MARK: - Rendering Variants

    private var gradientDove: some View {
        DoveSymbol()
            .fill(
                LinearGradient(
                    colors: [
                        BloomColors.primaryRose,
                        BloomColors.accentPeach
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
    }

    private var filledDove: some View {
        DoveSymbol()
            .fill(BloomColors.primaryRose)
            .frame(width: size, height: size)
    }

    private var outlinedDove: some View {
        DoveSymbol()
            .stroke(
                BloomColors.primaryRose,
                style: StrokeStyle(
                    lineWidth: max(1.5, size * 0.018),
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .frame(width: size, height: size)
    }
}

// MARK: - Trimmed Dove (for draw-on animation)

/// A trimmed version of `DoveSymbol` that supports the self-draw animation
/// used in `SplashScreenView`.  Feed `trim` from 0 → 1 over time.
struct TrimmedDoveSymbol: View {

    var trim: CGFloat     = 1.0
    var size: CGFloat     = 120
    var color: Color      = BloomColors.primaryRose
    var lineWidth: CGFloat?

    private var resolvedLineWidth: CGFloat {
        lineWidth ?? max(2, size * 0.022)
    }

    var body: some View {
        DoveSymbol()
            .trim(from: 0, to: trim)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: resolvedLineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .frame(width: size, height: size)
    }
}

// MARK: - Previews

#Preview("Dove — Gradient") {
    ZStack {
        BloomHerTheme.Colors.background.ignoresSafeArea()
        DoveSymbolView(size: 200, style: .gradient)
    }
}

#Preview("Dove — Outlined") {
    ZStack {
        BloomHerTheme.Colors.background.ignoresSafeArea()
        DoveSymbolView(size: 200, style: .outlined)
    }
}

#Preview("Dove — Filled") {
    ZStack {
        BloomHerTheme.Colors.background.ignoresSafeArea()
        DoveSymbolView(size: 200, style: .filled)
    }
}

#Preview("Dove — Trimmed at 50%") {
    ZStack {
        BloomHerTheme.Colors.background.ignoresSafeArea()
        TrimmedDoveSymbol(trim: 0.5, size: 200)
    }
}
