import JavaScriptKit
import Foundation

class App {
    let document = JSObject.global.document
    var game: Game
    let zoomCanvas: TransformingCanvas
    var body: JSValue { document.object!.body }
    var buttonsCallbacks: [JSClosure] = []
    let stylesheet = Stylesheet()
    let buttons = Buttons()
    var canvas: JSValue

    init() {
        let canvas = document.createElement("canvas")

        let cosmosCanvas = JSCanvas(canvas: canvas.object!)
        let zoomCanvas = TransformingCanvas(realCanvas: cosmosCanvas)
        zoomCanvas.fill(color: .black)

        self.canvas = canvas
        self.zoomCanvas = zoomCanvas
        self.game = Game(
            canvas: zoomCanvas,
            speed: .week,
            planets: .sol
        )

        _ = body.appendChild(canvas)
        setupUI()
    }

    func setupUI() {
        var zoomPlanetIndex = -1
        buttons.add(title: "Track next") { [unowned self] in
            zoomPlanetIndex += 1
            self.game.focus = self.game.planets[zoomPlanetIndex % self.game.planets.count].id
        }

        buttons.add(title: "Increase planet size") { [unowned self] in
            self.game.planetRadiusMultiplier = self.game.planetRadiusMultiplier * 1.5
        }
        buttons.add(title: "Decrease planet size") { [unowned self] in
            self.game.planetRadiusMultiplier = self.game.planetRadiusMultiplier / 1.5
        }

        var gen = SystemRandomNumberGenerator()
        func rnd(min: Double, max: Double) -> Double {
            return Double.random(in: min..<max, using: &gen)
        }
        buttons.add(title: "Random planets") { [unowned self] in
            self.game.stop()
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
        }
        buttons.add(title: "Home") { [unowned self] in
            self.game.stop()
            self.game = Game(
                canvas: self.zoomCanvas,
                speed: .week,
                planets: .sol
            )
            self.game.start()
        }

    }

    func start() {
        game.start()
    }
}

class Buttons {
    let document = JSObject.global.document

    var container: JSValue
    var buttonsCallbacks: [JSClosure] = []

    init() {
        let body: JSValue = document.object!.body

        var container = document.createElement("table")
        container.id = "buttonsContainer"
        _ = body.appendChild(container)

        let tr = document.createElement("tr")
        _ = container.appendChild(tr)

        self.container = tr
    }

    func add(title: String, action: @escaping () -> Void) {
        var button = document.createElement("button")
        button.innerHTML = .string(title)
        _ = makeTD().appendChild(button)


        let callback = JSClosure { _ in
            action()
            return .undefined
        }
        button.onclick = .object(callback)
        buttonsCallbacks.append(callback)
    }

    private func makeTD() -> JSValue {
        let td = document.createElement("td")
        _ = container.appendChild(td)
        return td
    }

}

class Stylesheet {

    init() {
        let document = JSObject.global.document
        let head: JSValue = document.object!.head

        var style = document.createElement("style")
        style.type = .string("text/css")
        style.innerHTML = .string(
            """
            html, body, div {
                margin: 0;
                padding: 0;
                border: 0;
                font-size: 100%;
                font: inherit;
                vertical-align: baseline;
            }
            canvas {
                height: 100%;
                width: 100%;
            }
            #buttonsContainer {
                position: absolute;
            }
            #buttonsContainer button {
                color: white;
                background: none;
                border: 1px solid #FFFFFF60;
            }
            #buttonsContainer button:hover {
                background: #FFFFFF40;
            }
            """)
        _ = head.appendChild(style)
    }
}
