import Foundation
import JavaScriptKit

protocol DrawCanvas {
    func clear()
    func fill(color: Color)
    func setStroke(color: Color)
    func drawCircle(origin: Point, radius: Double)
}

class JSCanvas: DrawCanvas {

    let context: JSObject
    let size: Dimension

    let liveColor = "#29fd2f"

    init(canvas: JSObject, size: Dimension) {
        self.size = size
        self.context = canvas.getContext!("2d").object!
        canvas.width = .number(size.width)
        canvas.height = .number(size.height)
    }

    func clear() {
        let rect = JSRect(origin: .zero, size: size)
        _ = context.clearRect!(rect.x, rect.y, rect.width, rect.height)
    }

    func fill(color: Color) {
        context.fillStyle = .string(color.value)
        let rect = JSRect(origin: .zero, size: size)
        _ = context.fillRect!(rect.x, rect.y, rect.width, rect.height)
    }

    func setStroke(color: Color) {
        context.strokeStyle = .string(color.value)
    }

    func setStroke(start: (Color, Point), end: (Color, Point)) {
        let grad = context.createLinearGradient!(
            start.1.x,
            start.1.y,
            end.1.x,
            end.1.y
        )
        _ = grad.addColorStop(0, start.0.value)
        _ = grad.addColorStop(1, end.0.value)

        context.strokeStyle = .object(grad.object!)
    }

    func setFill(color: Color) {
        context.fillStyle = .string(color.value)
    }

    func drawCircle(origin: Point, radius: Double) {
        _ = context.beginPath!()
        _ = context.arc!(origin.x, origin.y, radius, 0, 2 * Double.pi)
//        _ = context.fill!()
        _ = context.stroke!()
    }
    func drawFillCircle(origin: Point, radius: Double) {
        _ = context.beginPath!()
        _ = context.arc!(origin.x, origin.y, radius, 0, 2 * Double.pi)
        _ = context.fill!()
        _ = context.stroke!()
    }

    func drawLine(from: Point, to: Point) {
        _ = context.beginPath!()
        _ = context.moveTo!(from.x, from.y)
        _ = context.lineTo!(to.x, to.y)
        _ = context.stroke!()
    }

    func drawPath(points: [Point]) {
        guard points.isEmpty == false else { return }
        _ = context.beginPath!()
        let first = points.first!
        _ = context.moveTo!(first.x, first.y)
        for point in points.dropFirst() {
            _ = context.lineTo!(point.x, point.y)
        }
        _ = context.stroke!()
    }
}

class TransformingCanvas: DrawCanvas {
    let realCanvas: JSCanvas
    var zoom: Double = 1
    var offset: Point = .zero

    init(realCanvas: JSCanvas) {
        self.realCanvas = realCanvas
    }

    func clear() {
        realCanvas.clear()
    }

    func fill(color: Color) {
        realCanvas.fill(color: color)
    }

    func setStroke(color: Color) {
        realCanvas.setStroke(color: color)
    }

    func setStroke(start: (Color, Point), end: (Color, Point)) {
        realCanvas.setStroke(
            start: (start.0, (start.1 + offset) * zoom),
            end: (end.0, (end.1 + offset) * zoom)
        )
    }

    func setFill(color: Color) {
        realCanvas.setFill(color: color)
    }

    func drawCircle(origin: Point, radius: Double) {
        realCanvas.drawCircle(
            origin: (origin + offset) * zoom,
            radius: radius * zoom
        )
    }

    func drawFillCircle(origin: Point, radius: Double) {
        realCanvas.drawFillCircle(
            origin: (origin + offset) * zoom,
            radius: radius * zoom
        )
    }

    func drawLine(from: Point, to: Point) {
        realCanvas.drawLine(from: (from + offset) * zoom, to: (to + offset) * zoom)
    }

    func drawPath(points: [Point]) {
        realCanvas.drawPath(points: points.map { ($0 + offset) * zoom })
    }

}
