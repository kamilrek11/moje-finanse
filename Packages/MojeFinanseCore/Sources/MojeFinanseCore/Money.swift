import Foundation

/// Kwota w PLN jako liczba groszy. Jedyne miejsce parsowania, zaokrąglania i formatowania kwot.
public struct Money: Hashable, Comparable, Codable, Sendable {
    public let minorUnits: Int

    public init(minorUnits: Int) {
        self.minorUnits = minorUnits
    }

    public static let zero = Money(minorUnits: 0)
    /// 999 999 999,99 zł – górna granica kwot wpisywanych przez użytkownika.
    public static let maximum = Money(minorUnits: 99_999_999_999)

    /// Parsuje zapis typu "12,50", "12.50", "7". Odrzuca puste, ujemne, z literami,
    /// z więcej niż dwoma miejscami po przecinku i powyżej `maximum`.
    public init?(parsing text: String) {
        let parts = text.split(separator: ",", omittingEmptySubsequences: false)
            .flatMap { $0.split(separator: ".", omittingEmptySubsequences: false) }
        guard (1...2).contains(parts.count) else { return nil }
        let whole = parts[0]
        let fraction = parts.count == 2 ? parts[1] : ""
        guard !whole.isEmpty, whole.count <= 10, fraction.count <= 2 else { return nil }
        guard (whole + fraction).allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
        guard let zloty = Int(whole) else { return nil }
        let grosze = fraction.isEmpty ? 0 : Int(fraction)! * (fraction.count == 1 ? 10 : 1)
        let total = zloty * 100 + grosze
        guard total <= Money.maximum.minorUnits else { return nil }
        self.minorUnits = total
    }

    /// Zaokrągla kwotę w złotych do grosza (half up). Wynik jest ograniczony do ±`maximum`.
    public static func rounded(_ zloty: Decimal) -> Money {
        var cents = zloty * 100
        var result = Decimal()
        NSDecimalRound(&result, &cents, 0, .plain)
        let limit = Decimal(maximum.minorUnits)
        if result > limit { return maximum }
        if result < -limit { return Money(minorUnits: -maximum.minorUnits) }
        return Money(minorUnits: NSDecimalNumber(decimal: result).intValue)
    }

    public static func < (lhs: Money, rhs: Money) -> Bool { lhs.minorUnits < rhs.minorUnits }
    public static func + (lhs: Money, rhs: Money) -> Money { Money(minorUnits: lhs.minorUnits + rhs.minorUnits) }
    public static func - (lhs: Money, rhs: Money) -> Money { Money(minorUnits: lhs.minorUnits - rhs.minorUnits) }

    /// "12 345,67 zł" z U+00A0 jako separatorem tysięcy i przed "zł". Niezależne od ustawień regionalnych.
    public func formatted() -> String {
        let absolute = minorUnits.magnitude
        let whole = String(absolute / 100)
        var grouped = ""
        for (index, character) in whole.reversed().enumerated() {
            if index > 0 && index % 3 == 0 { grouped.append("\u{00A0}") }
            grouped.append(character)
        }
        let fraction = String(absolute % 100)
        let padded = fraction.count == 1 ? "0" + fraction : fraction
        let sign = minorUnits < 0 ? "-" : ""
        return "\(sign)\(String(grouped.reversed())),\(padded)\u{00A0}zł"
    }
}
