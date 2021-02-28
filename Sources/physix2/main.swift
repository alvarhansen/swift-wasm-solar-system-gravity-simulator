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


let app = App(
    canvas: zoomCanvas,
    speed: .week,
    planets: [
        .sun,
        .venus,
        .earth,
        .earthMoon,
        .mars
    ]
)

let toggle = JSClosure { _ in
    app.toggle()
    return .undefined
}

let zoomEarth = JSClosure { _ in
    app.focus = Planet.earth.id
    app.planetRadiusMultiplier = 10
    app.zoom = 1.0 / (pow(10.0, 6) * 3)
    return .undefined
}

let zoomSun = JSClosure { _ in
    app.focus = Planet.sun.id
    app.planetRadiusMultiplier = 1000
    app.zoom = 1.0 / (pow(10.0, 9) * 1)
    return .undefined
}

earthButton.onclick = .object(zoomEarth)
sunButton.onclick = .object(zoomSun)
canvas.onclick = .object(toggle)

app.start()

/*
 var gen = SystemRandomNumberGenerator()
 gen.next()

 func rnd(min: Double, max: Double) -> Double {
     min + (min + Double(gen.next())).truncatingRemainder(dividingBy: max)
 }

 print(rnd(min: 1, max: 5))
 */
