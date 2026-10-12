import XCTest
@testable import MojeFinanseCore

final class GoalPlannerTests: XCTestCase {
    private func zl(_ zloty: Int) -> Money { Money(minorUnits: zloty * 100) }

    private func warsaw(_ year: Int, _ month: Int, _ day: Int) -> Date {
        AppCalendar.calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private let now = Date(timeIntervalSince1970: 0)

    func testSpreadsTargetOverTwelveMonths() throws {
        let result = try GoalPlanner.requiredMonthlyContribution(
            target: zl(12_000), current: .zero, deadline: warsaw(2027, 10, 15), from: warsaw(2026, 10, 15))
        XCTAssertEqual(result, zl(1_000))
    }

    func testRoundsContributionUpToFullGrosz() throws {
        let result = try GoalPlanner.requiredMonthlyContribution(
            target: zl(1_000), current: .zero, deadline: warsaw(2027, 1, 15), from: warsaw(2026, 10, 15))
        XCTAssertEqual(result, Money(minorUnits: 33_334))
    }

    func testSubtractsCurrentAmount() throws {
        let result = try GoalPlanner.requiredMonthlyContribution(
            target: zl(1_200), current: zl(600), deadline: warsaw(2027, 4, 15), from: warsaw(2026, 10, 15))
        XCTAssertEqual(result, zl(100))
    }

    func testReachedGoalNeedsNothingEvenWithDeadlineInThePast() throws {
        let result = try GoalPlanner.requiredMonthlyContribution(
            target: zl(1_000), current: zl(1_000), deadline: warsaw(2020, 1, 1), from: warsaw(2026, 10, 15))
        XCTAssertEqual(result, .zero)
        XCTAssertEqual(try GoalPlanner.monthsToReach(target: zl(1_000), current: zl(2_000), monthlyContribution: .zero), 0)
    }

    func testDeadlineInCurrentOrPastMonthThrows() {
        for deadline in [warsaw(2026, 10, 31), warsaw(2026, 9, 1)] {
            XCTAssertThrowsError(try GoalPlanner.requiredMonthlyContribution(
                target: zl(1_000), current: .zero, deadline: deadline, from: warsaw(2026, 10, 15))) {
                XCTAssertEqual($0 as? GoalError, .deadlineNotInFuture)
            }
        }
    }

    func testMonthsToReachRoundsUp() throws {
        XCTAssertEqual(try GoalPlanner.monthsToReach(target: zl(1_000), current: .zero, monthlyContribution: zl(300)), 4)
        XCTAssertEqual(try GoalPlanner.monthsToReach(target: zl(900), current: .zero, monthlyContribution: zl(300)), 3)
    }

    func testZeroOrNegativeContributionThrows() {
        for contribution in [Money.zero, Money(minorUnits: -100)] {
            XCTAssertThrowsError(try GoalPlanner.monthsToReach(target: zl(1_000), current: .zero, monthlyContribution: contribution)) {
                XCTAssertEqual($0 as? GoalError, .noContribution)
            }
        }
    }

    func testGoalBalanceIncludesInitialDepositsAndWithdrawalsOfThatGoalOnly() {
        let goal = Goal(name: "Wakacje", target: zl(5_000), initial: zl(200))
        let other = Goal(name: "Laptop", target: zl(4_000))
        let transactions = [
            Transaction(date: now, amount: zl(500), kind: .goalDeposit, goalID: goal.id),
            Transaction(date: now, amount: zl(100), kind: .goalWithdrawal, goalID: goal.id),
            Transaction(date: now, amount: zl(999), kind: .goalDeposit, goalID: other.id),
            Transaction(date: now, amount: zl(999), kind: .fundDeposit)
        ]
        XCTAssertEqual(GoalPlanner.balance(of: goal, transactions: transactions), zl(600))
    }
}
