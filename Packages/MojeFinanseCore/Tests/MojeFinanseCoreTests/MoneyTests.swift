import XCTest
@testable import MojeFinanseCore

final class MoneyTests: XCTestCase {
    func testParsesCommaAndDot() {
        XCTAssertEqual(Money(parsing: "12,50")?.minorUnits, 1250)
        XCTAssertEqual(Money(parsing: "12.50")?.minorUnits, 1250)
        XCTAssertEqual(Money(parsing: "7")?.minorUnits, 700)
        XCTAssertEqual(Money(parsing: "0,05")?.minorUnits, 5)
    }

    func testRejectsInvalid() {
        for text in ["", "-5", "abc", "1,234", "1000000000"] {
            XCTAssertNil(Money(parsing: text), "powinno odrzucić: \(text)")
        }
    }

    func testAcceptsMaximum() {
        XCTAssertEqual(Money(parsing: "999999999,99"), Money.maximum)
    }

    func testRoundsHalfUp() {
        XCTAssertEqual(Money.rounded(Decimal(string: "0.125")!).minorUnits, 13)
        XCTAssertEqual(Money.rounded(Decimal(string: "0.124")!).minorUnits, 12)
    }

    func testFormatsPln() {
        XCTAssertEqual(Money(minorUnits: 1234567).formatted(), "12\u{00A0}345,67\u{00A0}zł")
        XCTAssertEqual(Money(minorUnits: 5).formatted(), "0,05\u{00A0}zł")
        XCTAssertEqual(Money.zero.formatted(), "0,00\u{00A0}zł")
    }

    func testAddsAndSubtracts() {
        XCTAssertEqual(Money(minorUnits: 100) + Money(minorUnits: 50), Money(minorUnits: 150))
        XCTAssertEqual(Money(minorUnits: 100) - Money(minorUnits: 150), Money(minorUnits: -50))
    }
}
