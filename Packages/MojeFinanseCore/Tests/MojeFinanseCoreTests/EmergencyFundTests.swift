import XCTest
@testable import MojeFinanseCore

final class EmergencyFundTests: XCTestCase {
    private func zl(_ zloty: Int) -> Money { Money(minorUnits: zloty * 100) }

    private func warsaw(_ year: Int, _ month: Int, _ day: Int) -> Date {
        AppCalendar.calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    func testAssessesShortfallAndMonthsCovered() throws {
        let result = try EmergencyFund.assess(monthlyEssentials: zl(3000), targetMonths: 6, balance: zl(6000))
        XCTAssertEqual(result.target, zl(18000))
        XCTAssertEqual(result.balance, zl(6000))
        XCTAssertEqual(result.shortfall, zl(12000))
        XCTAssertEqual(result.monthsCovered, Decimal(string: "2.0")!)
    }

    func testFullFundHasNoShortfallAndTruncatesToOneDecimal() throws {
        let result = try EmergencyFund.assess(monthlyEssentials: zl(3000), targetMonths: 6, balance: zl(20000))
        XCTAssertEqual(result.shortfall, .zero)
        XCTAssertEqual(result.monthsCovered, Decimal(string: "6.6")!)
    }

    func testNegativeBalanceCoversZeroMonths() throws {
        let result = try EmergencyFund.assess(monthlyEssentials: zl(3000), targetMonths: 3, balance: zl(-500))
        XCTAssertEqual(result.monthsCovered, 0)
        XCTAssertEqual(result.shortfall, zl(9500))
    }

    func testZeroEssentialsThrow() {
        XCTAssertThrowsError(try EmergencyFund.assess(monthlyEssentials: .zero, targetMonths: 3, balance: zl(100))) {
            XCTAssertEqual($0 as? FundError, .noEssentialCosts)
        }
    }

    func testTargetMonthsOutsideThreeToSixThrow() {
        for months in [2, 7] {
            XCTAssertThrowsError(try EmergencyFund.assess(monthlyEssentials: zl(3000), targetMonths: months, balance: zl(0))) {
                XCTAssertEqual($0 as? FundError, .targetMonthsOutOfRange)
            }
        }
    }

    func testMonthlyEssentialsUsesPreviousFullMonth() {
        let rent = Category(name: "Mieszkanie", symbol: "house", bucket: .needs, isEssential: true, sortOrder: 0)
        let fun = Category(name: "Rozrywka", symbol: "film", bucket: .wants, isEssential: false, sortOrder: 1)
        let settings = BudgetSettings(baseIncome: zl(5000), manualEssentialCosts: zl(999))
        let transactions = [
            Transaction(date: warsaw(2026, 9, 10), amount: zl(2800), kind: .expense, categoryID: rent.id),
            Transaction(date: warsaw(2026, 9, 12), amount: zl(300), kind: .expense, categoryID: fun.id),
            Transaction(date: warsaw(2026, 10, 3), amount: zl(1), kind: .expense, categoryID: rent.id)
        ]
        let result = EmergencyFund.monthlyEssentials(settings: settings, categories: [rent, fun],
                                                     transactions: transactions,
                                                     referenceMonth: CalendarMonth(year: 2026, month: 10))
        XCTAssertEqual(result, zl(2800))
    }

    func testMonthlyEssentialsFallsBackToManualValueThenZero() {
        let withManual = BudgetSettings(baseIncome: zl(5000), manualEssentialCosts: zl(2500))
        let withoutManual = BudgetSettings(baseIncome: zl(5000))
        let month = CalendarMonth(year: 2026, month: 10)
        XCTAssertEqual(EmergencyFund.monthlyEssentials(settings: withManual, categories: [], transactions: [], referenceMonth: month), zl(2500))
        XCTAssertEqual(EmergencyFund.monthlyEssentials(settings: withoutManual, categories: [], transactions: [], referenceMonth: month), .zero)
    }

    func testBalanceIncludesOpeningDepositsAndWithdrawals() {
        let settings = BudgetSettings(baseIncome: zl(5000), openingFundBalance: zl(1000))
        let transactions = [
            Transaction(date: warsaw(2026, 10, 1), amount: zl(400), kind: .fundDeposit),
            Transaction(date: warsaw(2026, 10, 2), amount: zl(150), kind: .fundWithdrawal),
            Transaction(date: warsaw(2026, 10, 3), amount: zl(999), kind: .goalDeposit)
        ]
        XCTAssertEqual(EmergencyFund.balance(settings: settings, transactions: transactions), zl(1250))
    }
}
