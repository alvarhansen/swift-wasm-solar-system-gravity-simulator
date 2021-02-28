import Foundation
import JavaScriptKit

print("Hello, worlds!", CGSize(width: 0, height: 0))


struct Color {
    var value: String

    static let white: Color = Color(value: "#FFF")
    static let red: Color = Color(value: "#F00")
    static let black: Color = Color(value: "#000")
    static let gray: Color = Color(value: "#888")
    static let green: Color = Color(value: "#0F0")
}


let document = JSObject.global.document

var body = document.object!.body
let canvas = document.createElement("canvas")
_ = body.appendChild(canvas)

let cosmosCanvas = JSCanvas(canvas: canvas.object!, size: Dimension(width: 900,height: 900))
let zoomCanvas = TransformingCanvas(realCanvas: cosmosCanvas)
zoomCanvas.fill(color: .black)

struct Identifier<Parent>: Hashable { let value: String }

struct Planet {
    var id: Identifier<Self>
    var color: Color
    var origin: Point
    var radius: Double
    var mass: Double
    var velocity: Vector2
    var drawRadiusMultiplier: Double = 1


    static let sun = Planet(
        id: .init(value: "Sun"),
        color: .init(value: "#FF0"),
        origin: Point(x: 0, y: 0),
        radius: 696.342 * pow(10, 6),
        mass: 1.9885 * pow(10, 30),
        velocity: .zero
    )

    static let venus = Planet(
        id: .init(value: "Venus"),
        color: .init(value: "#AAA"),
        origin: Point(x: 108.208 * pow(10, 9), y: 0),
        radius: 6.051 * pow(10, 6),
        mass: 4.8675 * pow(10, 24),
        velocity: Vector2(x: 0, y: 35.02 * pow(10, 3)),
        drawRadiusMultiplier: 10
    )

    static let earth = Planet(
        id: .init(value: "Earth"),
        color: .init(value: "#00F"),
        origin: Point(x: 1.495978707 * pow(10, 11), y: 0),
        radius: 6.3781 * pow(10, 6),
        mass: 5.972 * pow(10, 24),
        velocity: Vector2(x: 0, y: 29.29 * pow(10, 3)),
        drawRadiusMultiplier: 10
    )

    static let earthMoon = Planet(
        id: .init(value: "Earth Moon"),
        color: .init(value: "#DDD"),
        origin: Point(x: 1.495978707 * pow(10, 11) + 362.600 * pow(10, 6), y: 0),
        radius: 1.737 * pow(10, 6),
        mass: 7.342 * pow(10, 22),
        velocity: Vector2(x: 0, y: 29.29 * pow(10, 3) + 1.002 * pow(10, 3)),
        drawRadiusMultiplier: 10
    )

    static let mars = Planet(
        id: .init(value: "Mars"),
        color: .init(value: "#F33"),
        origin: Point(x: 2.492 * pow(10, 11), y: 0),
        radius: 3.389 * pow(10, 6),
        mass: 6.4171 * pow(10, 23),
        velocity: Vector2(x: 0, y: 24.007 * pow(10, 3)),
        drawRadiusMultiplier: 10
    )

}

extension Array {
    @inlinable public func update(_ transform: (inout Element) -> Void) -> [Element] {
        map { element -> Element in
            var copy = element
            transform(&copy)
            return copy
        }
    }
}

class App {

    let canvas: TransformingCanvas
    var planets: [Planet] = []
    var trails: [Identifier<Planet>: [Point]] = [:]
    static let tick: Double = 10

    var timer: JSValue?
    lazy var tickFn = JSClosure { [weak self] _ in
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
//        let origins = planets.map(\.origin) + [center]
//        let minX = origins.map(\.x).min()
//        let maxX = origins.map(\.x).max()
//        let minY = origins.map(\.y).min()
//        let maxY = origins.map(\.y).max()

//        canvas.offset = (Point(x: minX ?? 0, y: minY ?? 0) * -1)
        canvas.offset = Point(x: pow(10, 11) * 2.5, y: pow(10, 11) * 2.5)
        canvas.zoom = 1.0 / (pow(10.0, 8) * 6)
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
                let day: Double = 60 * 60 * 24
                let tenDays: Double = 10 * day
                let timeDelta: Double = tenDays / Self.tick
                let acceleration = force / planet.mass
                let velocity = planet.velocity + acceleration * timeDelta
                newPlanet.velocity = velocity
                newPlanet.origin = planet.origin + velocity * timeDelta
                return newPlanet
            }
    }

    func drawPlanets() {
        let planetRadiusMultiplier: Double = pow(10, 2)
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

let app = App(canvas: zoomCanvas)
app.planets = [
    .sun,
    .venus,
    .earth,
    .earthMoon,
    .mars
]

var gen = SystemRandomNumberGenerator()
gen.next()

func rnd(min: Double, max: Double) -> Double {
    min + (min + Double(gen.next())).truncatingRemainder(dividingBy: max)
}

print(rnd(min: 1, max: 5))

let toggle = JSClosure { _ in
    app.toggle()
    return .undefined
}

body.onclick = .object(toggle)

app.start()
//app.iterate()
//app.iterate()
//app.setTransform()
//app.drawPlanets()
