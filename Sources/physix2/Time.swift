struct Time {
    let value: Double

    static let hour = Time(value: 60 * 60)
    static let day = Time(value: 60 * 60 * 24)
    static let week = Time(value: 60 * 60 * 24 * 7)
}
