import XCTest
@testable import MojeFinanseCore

final class BudgetSummaryTests: XCTestCase {
    private let october = CalendarMonth(year: 2026, month: 10)
    private let rent = Category(name: "Mieszkanie", symbol: "house", bucket: .needs, isEssential: true, sortOrder: 0)
    private let fun = Category(name: "Rozrywka", symbol: "film", bucket: .wants, isEssential: false, sortOrder: 1)
    private let settings = BudgetSettings(baseIncome: Money(minorUnits: 500_000))

    private func warsaw(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0, _ second: Int = 0) -> Date {
        AppCalendar.calendar.date(from: DateComponents(year: year, month: month, day: day,
                                                       hour: hour, minute: minute, second: second))!
    }

    private func tx(_ kind: TransactionKind, _ minor: Int, category: Category? = nil,
                    on date: Date? = nil) -> Transaction {
        Transaction(date: date ?? warsaw(2026, 10, 15), amount: Money(minorUnits: minor),
                    kind: kind, categoryID: category?.id)
    }

    private func status(_ summary: BudgetSummary, _ bucket: Bucket) -> BucketStatus {
        summary.buckets.first { $0.bucket == bucket }!
    }

    func testTypicalMonth() {
        let summary = BudgetMath.summary(
            settings: settings, categories: [rent, fun],
            transactions: [tx(.expense, 120_000, category: rent), tx(.expense, 30_000, category: fun),
                           tx(.fundDeposit, 40_000)],
            month: october)
        XCTAssertEqual(summary.buckets.map(\.bucket), Bucket.allCases)
        XCTAssertEqual(status(summary, .needs).spent, Money(minorUnits: 120_000))
        XCTAssertEqual(status(summary, .wants).spent, Money(minorUnits: 30_000))
        XCTAssertEqual(status(summary, .savings).spent, Money(minorUnits: 40_000))
        XCTAssertEqual(status(summary, .needs).remaining, Money(minorUnits: 130_000))
        XCTAssertEqual(status(summary, .wants).remaining, Money(minorUnits: 120_000))
        XCTAssertEqual(status(summary, .savings).remaining, Money(minorUnits: 60_000))
        XCTAssertEqual(summary.essentialSpent, Money(minorUnits: 120_000))
    }

    func testExtraIncomeRaisesIncomeAndLimits() {
        let summary = BudgetMath.summary(settings: settings, categories: [], transactions: [tx(.income, 50_000)],
                                         month: october)
        XCTAssertEqual(summary.income, Money(minorUnits: 550_000))
        XCTAssertEqual(status(summary, .needs).limit, Money(minorUnits: 275_000))
    }

    func testGoalDepositCountsTowardSavings() {
        let summary = BudgetMath.summary(settings: settings, categories: [], transactions: [tx(.goalDeposit, 25_000)],
                                         month: october)
        XCTAssertEqual(status(summary, .savings).spent, Money(minorUnits: 25_000))
    }

    func testWithdrawalsDoNotChangeSavingsSpentOrIncome() {
        let summary = BudgetMath.summary(settings: settings, categories: [],
                                         transactions: [tx(.fundWithdrawal, 10_000), tx(.goalWithdrawal, 5_000)],
                                         month: october)
        XCTAssertEqual(status(summary, .savings).spent, .zero)
        XCTAssertEqual(summary.income, Money(minorUnits: 500_000))
    }

    func testArchivedCategoryStillCounts() {
        var archived = rent
        archived.isArchived = true
        let summary = BudgetMath.summary(settings: settings, categories: [archived, fun],
                                         transactions: [tx(.expense, 70_000, category: archived)], month: october)
        XCTAssertEqual(status(summary, .needs).spent, Money(minorUnits: 70_000))
        XCTAssertEqual(summary.essentialSpent, Money(minorUnits: 70_000))
    }

    func testExpenseWithUnknownCategoryIsUncategorized() {
        let ghost = Category(name: "Usunięta", symbol: "x", bucket: .wants, isEssential: false, sortOrder: 9)
        let summary = BudgetMath.summary(settings: settings, categories: [rent],
                                         transactions: [tx(.expense, 9_900, category: ghost), tx(.expense, 100)],
                                         month: october)
        XCTAssertEqual(summary.uncategorized, Money(minorUnits: 10_000))
        XCTAssertEqual(status(summary, .wants).spent, .zero)
    }

    func testMonthBoundaryUsesWarsawTime() {
        let lastSecond = tx(.expense, 1_000, category: fun, on: warsaw(2026, 10, 31, 23, 59, 59))
        let firstSecond = tx(.expense, 2_000, category: fun, on: warsaw(2026, 11, 1, 0, 0, 0))
        let november = CalendarMonth(year: 2026, month: 11)
        let inOctober = BudgetMath.summary(settings: settings, categories: [fun],
                                           transactions: [lastSecond, firstSecond], month: october)
        let inNovember = BudgetMath.summary(settings: settings, categories: [fun],
                                            transactions: [lastSecond, firstSecond], month: november)
        XCTAssertEqual(status(inOctober, .wants).spent, Money(minorUnits: 1_000))
        XCTAssertEqual(status(inNovember, .wants).spent, Money(minorUnits: 2_000))
    }

    func testMonthBoundaryAroundSpringDstChange() {
        let march = CalendarMonth(year: 2026, month: 3)
        let april = CalendarMonth(year: 2026, month: 4)
        let beforeChange = tx(.expense, 100, category: fun, on: warsaw(2026, 3, 28, 23, 30))
        let afterChange = tx(.expense, 200, category: fun, on: warsaw(2026, 3, 29, 3, 30))
        let marchEnd = tx(.expense, 400, category: fun, on: warsaw(2026, 3, 31, 23, 59, 59))
        let aprilStart = tx(.expense, 800, category: fun, on: warsaw(2026, 4, 1, 0, 0, 0))
        let all = [beforeChange, afterChange, marchEnd, aprilStart]
        XCTAssertEqual(status(BudgetMath.summary(settings: settings, categories: [fun], transactions: all, month: march), .wants).spent,
                       Money(minorUnits: 700))
        XCTAssertEqual(status(BudgetMath.summary(settings: settings, categories: [fun], transactions: all, month: april), .wants).spent,
                       Money(minorUnits: 800))
    }

    func testZeroIncomeGivesZeroLimitsWithoutCrash() {
        let zero = BudgetSettings(baseIncome: .zero)
        let summary = BudgetMath.summary(settings: zero, categories: [fun],
                                         transactions: [tx(.expense, 5_000, category: fun)], month: october)
        XCTAssertTrue(summary.buckets.allSatisfy { $0.limit == .zero })
        XCTAssertEqual(status(summary, .wants).remaining, Money(minorUnits: -5_000))
    }

    func testVeryLargeAmountsDoNotOverflow() {
        let huge = BudgetSettings(baseIncome: .maximum)
        let summary = BudgetMath.summary(settings: huge, categories: [rent],
                                         transactions: [tx(.income, Money.maximum.minorUnits),
                                                        tx(.expense, Money.maximum.minorUnits, category: rent),
                                                        tx(.expense, Money.maximum.minorUnits, category: rent)],
                                         month: october)
        XCTAssertEqual(summary.income.minorUnits, 2 * Money.maximum.minorUnits)
        XCTAssertEqual(status(summary, .needs).spent.minorUnits, 2 * Money.maximum.minorUnits)
    }
}
