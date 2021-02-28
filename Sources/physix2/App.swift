import JavaScriptKit
import Foundation

class App {
    let document = JSObject.global.document
    var game: Game
    let zoomCanvas: TransformingCanvas
    var body: JSValue { document.object!.body }
    var buttonsCallbacks: [JSClosure] = []

    init() {
        let canvas = document.createElement("canvas")

        let cosmosCanvas = JSCanvas(canvas: canvas.object!, size: Dimension(width: 900,height: 900))
        let zoomCanvas = TransformingCanvas(realCanvas: cosmosCanvas)
        zoomCanvas.fill(color: .black)

        self.zoomCanvas = zoomCanvas
        self.game = Game(
            canvas: zoomCanvas,
            speed: .week,
            planets: [.sun, .venus, .earth, .earthMoon, .mars]
        )

        _ = body.appendChild(canvas)
        setupUI()
    }

    func setupUI() {
        var earthButton = document.createElement("button")
        earthButton.innerHTML = "Earth"
        _ = body.appendChild(earthButton)

        var sunButton = document.createElement("button")
        sunButton.innerHTML = "Sun"
        _ = body.appendChild(sunButton)

        var restartButton = document.createElement("button")
        restartButton.innerHTML = "reset random"
        _ = body.appendChild(restartButton)

        var zoomPlanetIndex = -1
        let zoomEarth = JSClosure { [unowned self] _ in
            zoomPlanetIndex += 1
            self.game.focus = self.game.planets[zoomPlanetIndex % self.game.planets.count].id
            self.game.planetRadiusMultiplier = 100
            self.game.zoom = 1.0 / (pow(10.0, 8) * 3)
            return .undefined
        }

        var zoomIndex = -1
        let zoomSun = JSClosure { [weak self] _ in
            zoomIndex += 1
            let steps: [Double] = [9, 10]
            let step = steps[zoomIndex % steps.count]
            self?.game.planetRadiusMultiplier = 1000
            self?.game.zoom = 1.0 / (pow(10.0, step) * 1)
            return .undefined
        }

        let reset = JSClosure { _ in
            self.game.stop()

            var gen = SystemRandomNumberGenerator()
            func rnd(min: Double, max: Double) -> Double {
                return Double.random(in: min..<max, using: &gen)
            }
            self.game = Game(
                canvas: self.zoomCanvas,
                speed: Time(value: Time.week.value * 10),
                planets: (0..<3).map { i in
                    Planet(
                        id: .init(value: "Planet \(i)"),
                        color: .init(value: "#00F"),
                        origin: Point(
                         x: rnd(min: -3, max: 3) * pow(10, 11),
                         y: rnd(min: -3, max: 3) * pow(10, 11)
                        ),
                        radius: 6.3781 * pow(10, 6),
                        mass: pow(10, rnd(min: 25, max: 30)),
                        velocity: Vector2(
                         x: rnd(min: -10, max: 10) * pow(10, 3),
                         y: rnd(min: -10, max: 10) * pow(10, 3)
                        )
                    )
                 }
            )
            self.game.start()
            return .undefined
        }

        buttonsCallbacks.append(contentsOf: [zoomEarth, zoomSun, reset])
        earthButton.onclick = .object(zoomEarth)
        sunButton.onclick = .object(zoomSun)
        restartButton.onclick = .object(reset)

    }

    func start() {
        game.start()
    }
}
