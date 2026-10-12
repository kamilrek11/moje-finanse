import XCTest
@testable import MojeFinanseCore

final class BudgetLimitsTests: XCTestCase {
    func testSplits503020OfRoundIncome() {
        let limits = BudgetMath.limits(income: Money(minorUnits: 500_000), shares: .standard)
        XCTAssertEqual(limits[.needs], Money(minorUnits: 250_000))
        XCTAssertEqual(limits[.wants], Money(minorUnits: 150_000))
        XCTAssertEqual(limits[.savings], Money(minorUnits: 100_000))
    }

    func testLimitsAlwaysSumToIncomeWithLargestRemainder() {
        let limits = BudgetMath.limits(income: Money(minorUnits: 10_001), shares: .standard)
        XCTAssertEqual(limits[.needs], Money(minorUnits: 5_001))
        XCTAssertEqual(limits[.wants], Money(minorUnits: 3_000))
        XCTAssertEqual(limits[.savings], Money(minorUnits: 2_000))
        XCTAssertEqual(limits.values.reduce(Money.zero, +), Money(minorUnits: 10_001))
    }

    func testZeroIncomeGivesZeroLimits() {
        let limits = BudgetMath.limits(income: .zero, shares: .standard)
        XCTAssertEqual(Set(limits.keys), Set(Bucket.allCases))
        XCTAssertTrue(limits.values.allSatisfy { $0 == .zero })
    }

    func testOneGroszGoesToExactlyOneBucket() {
        let limits = BudgetMath.limits(income: Money(minorUnits: 1), shares: .standard)
        XCTAssertEqual(limits.values.reduce(Money.zero, +), Money(minorUnits: 1))
        XCTAssertEqual(limits[.needs], Money(minorUnits: 1))
    }

    func testNegativeIncomeIsTreatedAsZero() {
        let limits = BudgetMath.limits(income: Money(minorUnits: -500), shares: .standard)
        XCTAssertTrue(limits.values.allSatisfy { $0 == .zero })
    }

    func testCustomSharesAreRespected() throws {
        let shares = try BucketShares(needs: 60, wants: 10, savings: 30)
        let limits = BudgetMath.limits(income: Money(minorUnits: 100_000), shares: shares)
        XCTAssertEqual(limits[.needs], Money(minorUnits: 60_000))
        XCTAssertEqual(limits[.wants], Money(minorUnits: 10_000))
        XCTAssertEqual(limits[.savings], Money(minorUnits: 30_000))
    }
}
