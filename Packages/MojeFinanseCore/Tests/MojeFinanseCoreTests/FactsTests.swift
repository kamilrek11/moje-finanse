import XCTest
@testable import MojeFinanseCore

final class FactsTests: XCTestCase {
    private let sample = """
    {
      "schemaVersion": 1,
      "facts": [
        {
          "key": "belka.rate",
          "value": "19%",
          "sourceName": "Ustawa o podatku dochodowym od osób fizycznych",
          "sourceURL": "https://example.gov.pl/pit",
          "verifiedOn": "2026-10-11"
        }
      ]
    }
    """

    private func warsaw(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
        AppCalendar.calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    func testDecodesFactsFile() throws {
        let file = try FactsFile.decode(from: Data(sample.utf8))
        XCTAssertEqual(file.schemaVersion, 1)
        XCTAssertEqual(file.facts.count, 1)
        XCTAssertEqual(file.facts[0].value, "19%")
        XCTAssertEqual(file.facts[0].sourceURL, URL(string: "https://example.gov.pl/pit"))
        XCTAssertEqual(CalendarMonth(containing: file.facts[0].verifiedOn), CalendarMonth(year: 2026, month: 10))
        XCTAssertEqual(AppCalendar.calendar.component(.day, from: file.facts[0].verifiedOn), 11)
    }

    func testFactLookupByKey() throws {
        let file = try FactsFile.decode(from: Data(sample.utf8))
        XCTAssertEqual(file.fact(for: "belka.rate")?.value, "19%")
        XCTAssertNil(file.fact(for: "missing"))
    }

    func testStalenessBoundary() throws {
        let fact = try FactsFile.decode(from: Data(sample.utf8)).facts[0] // zweryfikowany 2026-10-11
        XCTAssertFalse(fact.isStale(asOf: warsaw(2026, 10, 11, 23), maxAgeDays: 0))
        XCTAssertFalse(fact.isStale(asOf: warsaw(2026, 11, 10), maxAgeDays: 30)) // dokładnie 30 dni
        XCTAssertTrue(fact.isStale(asOf: warsaw(2026, 11, 11), maxAgeDays: 30))  // 31 dni
    }

    func testInvalidDateThrows() {
        let broken = sample.replacingOccurrences(of: "2026-10-11", with: "11.10.2026")
        XCTAssertThrowsError(try FactsFile.decode(from: Data(broken.utf8)))
        let impossible = sample.replacingOccurrences(of: "2026-10-11", with: "2026-13-45")
        XCTAssertThrowsError(try FactsFile.decode(from: Data(impossible.utf8)))
    }
}
