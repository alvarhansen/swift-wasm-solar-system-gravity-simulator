import Foundation
import JavaScriptKit

class App {

    let canvas: TransformingCanvas
    var planets: [Planet] = []

    var focus = Planet.sun.id
    var zoom: Double = 1.0 / (pow(10.0, 9) * 1)
    var planetRadiusMultiplier: Double = 1000

    var trails: [Identifier<Planet>: [Point]] = [:]

    var speed: Time = .day

    static let tick: Double = 10

    var timer: JSValue?

    private lazy var tickFn = JSClosure { [weak self] _ in
        self?.iterate()
        return .undefined
    }

    init(canvas: TransformingCanvas) {
        self.canvas = canvas
    }

    func start() {
        cosmosCanvas.fill(color: .black)
        timer = JSObject.global.setInterval!(tickFn, Self.tick)
    }

    func stop() {
        _ = JSObject.global.clearInterval!(timer)
        timer = nil
    }

    func toggle() {
        if let _ = timer {
            stop()
        } else {
            start()
        }
    }

    var iteration = 0

    func iterate() {
        iteration += 1
        updateTrail()

        movePlanets()

        setTransform()

        canvas.clear()
        canvas.fill(color: .black)

        drawTrail()

        drawPlanets()
    }

    func updateTrail() {
        let maxTrailLength = 100
        guard iteration % 3 == 0 else {
            return
        }
        for planet in planets {
            trails[planet.id, default: []].append(planet.origin)
            if trails[planet.id]!.count > maxTrailLength {
                trails[planet.id] = Array(trails[planet.id, default: []].dropFirst())
            }
        }
    }

    func setTransform() {
        canvas.zoom = zoom
        canvas.offset = Point(x: canvas.realCanvas.size.width / 2, y: canvas.realCanvas.size.height / 2) / canvas.zoom
        canvas.offset = canvas.offset + (planets.first(where: { $0.id == focus })?.origin ?? .zero) * -1
    }

    func movePlanets() {
        func gForce(p1: Planet, p2: Planet) -> Vector2 {
            let distance: Vector2 = (p2.origin - p1.origin).vector
            let k: Double = 6.6742 * pow(10, -11)
            let magnitude = distance.magnitude
            guard magnitude > 1 else { return .zero }
            let force = k * (p1.mass * p2.mass) / pow(magnitude, 2)
            let forceVector = distance * (force / magnitude)
            return forceVector
        }
        planets = planets
            .map { p -> (Planet, Vector2) in
                let force = planets
                    .filter { $0.id != p.id }
                    .reduce(into: .zero) { (force, p2) in
                        force = force + gForce(p1: p, p2: p2)
                    }
                return (p, force)
            }
            .map { (planet, force) in
                var newPlanet = planet
                let timeDelta: Double = speed.value / Self.tick
                let acceleration = force / planet.mass
                let velocity = planet.velocity + acceleration * timeDelta
                newPlanet.velocity = velocity
                newPlanet.origin = planet.origin + velocity * timeDelta
                return newPlanet
            }
    }

    func drawPlanets() {
        for planet in planets {
            canvas.setStroke(color: planet.color)
            canvas.setFill(color: planet.color)
            canvas.drawFillCircle(
                origin: planet.origin,
                radius: planet.radius * planet.drawRadiusMultiplier * planetRadiusMultiplier
            )
        }
    }

    func drawTrail() {
        let colors = [
            (Color(value: "rgba(255,255,0,0)"), Color(value: "#FF0")),
            (Color(value: "rgba(255,255,255,0)"), .white),
            (Color(value: "rgba(255,0,0,0)"), .red)
        ]

        for (idx, trail) in trails.enumerated() {
            canvas.setStroke(color: colors[idx % colors.count].1)
            canvas.drawPath(points: trail.value)
        }
    }
}
