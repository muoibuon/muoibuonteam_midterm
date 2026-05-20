import SwiftUI

// MARK: - Particle
private struct Particle {
    var x, y, z: Double
    let speed, hue, alpha, radius: Double

    static func make(randomZ: Bool) -> Particle {
        let pink = Double.random(in: 0...1) < 0.6
        return Particle(
            x:      .random(in: -1500...1500),
            y:      .random(in: -1500...1500),
            z:      randomZ ? .random(in: 10...500) : 500,
            speed:  .random(in: 0.15...0.48),
            hue:    pink ? .random(in: 0.78...0.92) : .random(in: 0.47...0.58),
            alpha:  .random(in: 0.55...1.0),
            radius: .random(in: 1.0...3.4)
        )
    }
}

// MARK: - Engine (reference type — mutated inside Canvas each frame)
private final class Engine {
    private let fov = 500.0
    var pts: [Particle]
    var camX = 0.0, camY = 0.0

    init() { pts = (0..<80).map { _ in .make(randomZ: true) } }

    func tick(normX: Double, normY: Double) {
        let tx = (normX - 0.5) * 2
        let ty = (normY - 0.5) * 2
        camX += (tx - camX) * 0.042
        camY += (ty - camY) * 0.042
        for i in pts.indices {
            pts[i].z -= pts[i].speed
            if pts[i].z <= 0 { pts[i] = .make(randomZ: false) }
        }
    }

    struct Proj { let x, y, sz, al, hue: Double }

    func project(_ p: Particle, w: Double, h: Double) -> Proj? {
        let scale = fov / (fov + p.z)
        let sx = p.x * scale + w * 0.5 + camX * 80
        let sy = p.y * scale + h * 0.5 + camY * 50
        guard sx > -20, sx < w + 20, sy > -20, sy < h + 20 else { return nil }
        return Proj(x: sx, y: sy,
                    sz: max(0.5, p.radius * scale),
                    al: p.alpha * min(1.0, scale * 2.2),
                    hue: p.hue)
    }
}

// MARK: - ParticleLayer View
struct ParticleLayer: View {
    @State private var engine    = Engine()
    @State private var normMouse = CGPoint(x: 0.5, y: 0.5)

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { _ in
                Canvas { ctx, size in
                    engine.tick(normX: normMouse.x, normY: normMouse.y)
                    let W = size.width, H = size.height
                    let proj = engine.pts.compactMap { engine.project($0, w: W, h: H) }

                    // Connection lines (O(n²) — fine at n=80)
                    for i in 0..<proj.count {
                        for j in (i + 1)..<proj.count {
                            let a = proj[i], b = proj[j]
                            let d = hypot(a.x - b.x, a.y - b.y)
                            guard d < 120 else { continue }
                            let al = (1 - d / 120) * 0.22 * min(a.al, b.al)
                            var path = Path()
                            path.move(to: CGPoint(x: a.x, y: a.y))
                            path.addLine(to: CGPoint(x: b.x, y: b.y))
                            ctx.stroke(
                                path,
                                with: .color(
                                    Color(hue: (a.hue + b.hue) / 2, saturation: 0.85, brightness: 0.9)
                                        .opacity(al)
                                ),
                                lineWidth: 0.8
                            )
                        }
                    }

                    // Particles: outer glow → inner glow → white core
                    for p in proj {
                        let c = Color(hue: p.hue, saturation: 0.95, brightness: 1.0)
                        ctx.fill(circle(p.x, p.y, p.sz * 13), with: .color(c.opacity(p.al * 0.16)))
                        ctx.fill(circle(p.x, p.y, p.sz * 5),  with: .color(c.opacity(p.al * 0.55)))
                        ctx.fill(circle(p.x, p.y, p.sz * 0.85), with: .color(.white.opacity(p.al)))
                    }
                }
            }
            .onContinuousHover { phase in
                guard case .active(let loc) = phase else { return }
                let w = geo.size.width, h = geo.size.height
                normMouse = CGPoint(
                    x: w > 0 ? loc.x / w : 0.5,
                    y: h > 0 ? loc.y / h : 0.5
                )
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func circle(_ x: Double, _ y: Double, _ r: Double) -> Path {
        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
    }
}
