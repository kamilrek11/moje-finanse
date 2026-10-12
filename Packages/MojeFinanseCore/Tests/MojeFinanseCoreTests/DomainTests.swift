import XCTest
@testable import MojeFinanseCore

final class DomainTests: XCTestCase {
    func testStandardSharesAre503020() {
        XCTAssertEqual(BucketShares.standard.needs, 50)
        XCTAssertEqual(BucketShares.standard.wants, 30)
        XCTAssertEqual(BucketShares.standard.savings, 20)
    }

    func testSharesNotSummingTo100Throw() {
        XCTAssertThrowsError(try BucketShares(needs: 50, wants: 30, savings: 30)) {
            XCTAssertEqual($0 as? BudgetError, .sharesMustSumTo100)
        }
    }

    func testNegativeSharesThrowEvenWhenSumIs100() {
        XCTAssertThrowsError(try BucketShares(needs: 110, wants: -5, savings: -5)) {
            XCTAssertEqual($0 as? BudgetError, .sharesMustSumTo100)
        }
    }

    func testTransactionRoundTripsThroughJSON() throws {
        let original = Transaction(id: UUID(), date: Date(timeIntervalSince1970: 1_790_000_000),
                                   amount: Money(minorUnits: 1250), kind: .expense,
                                   categoryID: UUID(), goalID: nil, note: "kawa")
        let data = try JSONEncoder().encode(original)
        XCTAssertEqual(try JSONDecoder().decode(Transaction.self, from: data), original)
    }

    func testBudgetSettingsRoundTripsThroughJSON() throws {
        let original = BudgetSettings(baseIncome: Money(minorUnits: 500_000), shares: .standard,
                                      manualEssentialCosts: Money(minorUnits: 300_000),
                                      fundTargetMonths: 3, openingFundBalance: Money(minorUnits: 100_000))
        let data = try JSONEncoder().encode(original)
        XCTAssertEqual(try JSONDecoder().decode(BudgetSettings.self, from: data), original)
    }

    func testBucketOrderIsNeedsWantsSavings() {
        XCTAssertEqual(Bucket.allCases, [.needs, .wants, .savings])
    }

    func testCalendarMonthAddingRollsOverYear() {
        XCTAssertEqual(CalendarMonth(year: 2026, month: 12).adding(months: 1), CalendarMonth(year: 2027, month: 1))
        XCTAssertEqual(CalendarMonth(year: 2026, month: 1).adding(months: -1), CalendarMonth(year: 2025, month: 12))
    }

    func testCalendarMonthsAreComparable() {
        XCTAssertLessThan(CalendarMonth(year: 2026, month: 10), CalendarMonth(year: 2026, month: 11))
        XCTAssertLessThan(CalendarMonth(year: 2025, month: 12), CalendarMonth(year: 2026, month: 1))
    }

    func testMonthContainingUsesWarsawTimeZone() {
        let iso = ISO8601DateFormatter()
        // 2026-10-31 23:59:59 w Warszawie (UTC+1) to jeszcze październik...
        XCTAssertEqual(CalendarMonth(containing: iso.date(from: "2026-10-31T22:59:59Z")!), CalendarMonth(year: 2026, month: 10))
        // ... a 00:00:00 1 listopada w Warszawie to już listopad.
        XCTAssertEqual(CalendarMonth(containing: iso.date(from: "2026-10-31T23:00:00Z")!), CalendarMonth(year: 2026, month: 11))
    }

    func testMonthIntervalStartsAndEndsAtWarsawMidnight() {
        let iso = ISO8601DateFormatter()
        let interval = CalendarMonth(year: 2026, month: 10).interval
        XCTAssertEqual(interval.start, iso.date(from: "2026-09-30T22:00:00Z")!) // 1.10 00:00 CEST
        XCTAssertEqual(interval.end, iso.date(from: "2026-10-31T23:00:00Z")!)   // 1.11 00:00 CET
    }
}
