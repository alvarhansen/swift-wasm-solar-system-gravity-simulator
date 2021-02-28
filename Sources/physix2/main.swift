import Foundation
import JavaScriptKit

print("Hello, worlds!")


let document = JSObject.global.document

var body = document.object!.body
var canvas = document.createElement("canvas")
_ = body.appendChild(canvas)

let cosmosCanvas = JSCanvas(canvas: canvas.object!, size: Dimension(width: 900,height: 900))
let zoomCanvas = TransformingCanvas(realCanvas: cosmosCanvas)
zoomCanvas.fill(color: .black)

var earthButton = document.createElement("button")
earthButton.innerHTML = "Earth"
_ = body.appendChild(earthButton)

var sunButton = document.createElement("button")
sunButton.innerHTML = "Sun"
_ = body.appendChild(sunButton)


var restartButton = document.createElement("button")
restartButton.innerHTML = "reset random"
_ = body.appendChild(restartButton)

var game = Game(
    canvas: zoomCanvas,
    speed: .week,
    planets: [.sun, .venus, .earth, .earthMoon, .mars]
)

let toggle = JSClosure { _ in
    game.toggle()
    return .undefined
}

var zoomPlanetIndex = -1
let zoomEarth = JSClosure { _ in
    zoomPlanetIndex += 1
    game.focus = game.planets[zoomPlanetIndex % game.planets.count].id
    game.planetRadiusMultiplier = 100
    game.zoom = 1.0 / (pow(10.0, 8) * 3)
    return .undefined
}

var zoomIndex = -1
let zoomSun = JSClosure { _ in
    zoomIndex += 1
    let steps: [Double] = [9, 10]
    let step = steps[zoomIndex % steps.count]
    game.planetRadiusMultiplier = 1000
    game.zoom = 1.0 / (pow(10.0, step) * 1)
    return .undefined
}

let reset = JSClosure { _ in
    game.stop()


    var gen = SystemRandomNumberGenerator()
    func rnd(min: Double, max: Double) -> Double {
        return Double.random(in: min..<max, using: &gen)
    }
    game = Game(
        canvas: zoomCanvas,
        speed: Time(value: Time.week.value * 10),
        planets: (0..<3).map { i in
            Planet(
                id: .init(value: "Earth\(i)"),
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
    game.start()
    return .undefined
}

earthButton.onclick = .object(zoomEarth)
sunButton.onclick = .object(zoomSun)
restartButton.onclick = .object(reset)

game.start()

