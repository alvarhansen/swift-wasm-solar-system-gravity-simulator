import Foundation
import JavaScriptKit

class Game {

    var log: ((String) -> Void)?

    let iterationInterval: Double = 33
    let canvas: TransformingCanvas
    let speed: Time

    var focus: Identifier<Planet>?
    var zoom: Double = 1.0 / (pow(10.0, 9) * 2)
    var planetRadiusMultiplier: Double = 1000

    private(set) var planets: [Planet] = []
    private var trails: [Identifier<Planet>: [Point]] = [:]
    private var timer: JSValue?

    private lazy var tickFn: JSClosure! = JSClosure { [weak self] _ in
        self?.iterate()
        return .undefined
    }

    deinit {
        tickFn.release()
    }

    init(
        canvas: TransformingCanvas,
        speed: Time = .day,
        planets: [Planet]
    ) {
        self.canvas = canvas
        self.speed = speed
        self.planets = planets
    }

    func start() {
        canvas.fill(color: .black)
        timer = JSObject.global.setInterval!(tickFn, iterationInterval)
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

        canvas.updateSize()
        autoZoom()
        setTransform()

        canvas.clear()
        canvas.fill(color: .black)

        drawTrail()

        drawPlanets()

        let logMessage = planets.map { planet -> String in
            """
            \(focus == planet.id ? "►" : "")\(planet.id.value) | Mass: \(planet.mass)
              Position: x: \(planet.origin.x) y: \(planet.origin.y)
              Velocity: x: \(planet.velocity.x) y: \(planet.velocity.y)
            """
        }.joined(separator: "\n")
        log?("""
            iteration: \(iteration) | zoom: \(zoom)
            \(logMessage)
            """)
    }

    func updateTrail() {
        let maxTrailLength = 100
        for planet in planets {
            trails[planet.id, default: []].append(planet.origin)
            if trails[planet.id]!.count > maxTrailLength {
                trails[planet.id] = Array(trails[planet.id, default: []].dropFirst())
            }
        }
    }

    func autoZoom() {
        let centre = (planets.first(where: { $0.id == focus })?.origin ?? .zero)
        let maxDistance: Double = planets.map {
            ($0.origin - centre).vector.magnitude
        }.max()!

        let minSide = min(canvas.realCanvas.size.width, canvas.realCanvas.size.height)
        zoom = minSide / maxDistance / 2.1 //2x for centred view, 0.1x for padding
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
                let timeDelta: Double = speed.value / iterationInterval
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
        for (idx, trail) in trails.enumerated() {
            canvas.setStroke(color: planets[idx].color)
            canvas.drawPath(points: trail.value)
        }
    }
}

extension Game {

    static func makeSol(canvas: TransformingCanvas) -> Game {
        Game(
            canvas: canvas,
            speed: .week,
            planets: .sol
        )
    }

    static func makeRandom(canvas: TransformingCanvas) -> Game {
        var gen = SystemRandomNumberGenerator()
        func rnd(min: Double, max: Double) -> Double {
            return Double.random(in: min..<max, using: &gen)
        }

        let colors = ["#845EC2", "#D65DB1", "#FF6F91", "#FF9671", "#FFC75F", "#F9F871"].shuffled()
        return Game(
            canvas: canvas,
            speed: Time(value: Time.week.value * 10),
            planets: (0..<3).map { i in
                Planet(
                    id: .init(value: "Planet \(i)"),
                    color: .init(value: colors[i % colors.count]),
                    origin: Point(
                        x: rnd(min: -3, max: 3) * pow(10, 11),
                        y: rnd(min: -3, max: 3) * pow(10, 11)
                    ),
                    radius: 6.3781 * pow(10, 6),
                    mass: rnd(min: 1, max: 2) * pow(10, 29),
                    velocity: Vector2(
                        x: rnd(min: -10, max: 10) * pow(10, 3),
                        y: rnd(min: -10, max: 10) * pow(10, 3)
                    )
                )
            }
        )
    }
}
