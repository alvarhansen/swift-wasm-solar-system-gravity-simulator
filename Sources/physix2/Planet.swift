import Foundation

struct Identifier<Parent>: Hashable {
    let value: String
}

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
        velocity: .zero,
        drawRadiusMultiplier: 0.05
    )

    static let mercury = Planet(
        id: .init(value: "Mercury"),
        color: .init(value: "#828282"),
        origin: Point(x: 69.8169 * pow(10, 9), y: 0),
        radius: 2.4397 * pow(10, 3),
        mass: 3.3011 * pow(10, 23),
        velocity: Vector2(x: 0, y: 47.362 * pow(10, 3)),
        drawRadiusMultiplier: 1000
    )

    static let venus = Planet(
        id: .init(value: "Venus"),
        color: .init(value: "#AAA"),
        origin: Point(x: 108.208 * pow(10, 9), y: 0),
        radius: 6.051 * pow(10, 6),
        mass: 4.8675 * pow(10, 24),
        velocity: Vector2(x: 0, y: 35.02 * pow(10, 3)),
        drawRadiusMultiplier: 0.5
    )

    static let earth = Planet(
        id: .init(value: "Earth"),
        color: .init(value: "#00F"),
        origin: Point(x: 1.495978707 * pow(10, 11), y: 0),
        radius: 6.3781 * pow(10, 6),
        mass: 5.972 * pow(10, 24),
        velocity: Vector2(x: 0, y: 29.29 * pow(10, 3))
    )

    static let earthMoon = Planet(
        id: .init(value: "Earth Moon"),
        color: .init(value: "#DDD"),
        origin: Point(x: 1.495978707 * pow(10, 11) + 362.600 * pow(10, 6), y: 0),
        radius: 1.737 * pow(10, 6),
        mass: 7.342 * pow(10, 22),
        velocity: Vector2(x: 0, y: 29.29 * pow(10, 3) + 1.002 * pow(10, 3))
    )

    static let mars = Planet(
        id: .init(value: "Mars"),
        color: .init(value: "#F33"),
        origin: Point(x: 2.492 * pow(10, 11), y: 0),
        radius: 3.389 * pow(10, 6),
        mass: 6.4171 * pow(10, 23),
        velocity: Vector2(x: 0, y: 24.007 * pow(10, 3))
    )


    static let jupiter = Planet(
        id: .init(value: "Jupiter"),
        color: .init(value: "rgb(192,130,65)"),
        origin: Point(x: 816.62 * pow(10, 9), y: 0),
        radius: 69.911 * pow(10, 6),
        mass: 1.8982 * pow(10, 27),
        velocity: Vector2(x: 0, y: 24.007 * pow(10, 3)),
        drawRadiusMultiplier: 0.1
    )

}

extension Array where Element == Planet {
    static var sol: [Planet] = [
        .sun,
        .mercury,
        .venus,
        .mars,
        .earth,
        .earthMoon,
//        .jupiter
    ]
}
