import XCTest
import MojeFinanseCore
@testable import MojeFinanse

final class MappingTests: XCTestCase {
    func testCategoryRoundTripKeepsEveryField() {
        let category = Category(name: "Jedzenie", symbol: "cart", bucket: .wants, isEssential: true,
                                sortOrder: 7, isArchived: true)
        XCTAssertEqual(CategoryEntity(category).domain, category)
    }

    func testTransactionRoundTripKeepsEveryField() {
        let transaction = Transaction(date: Date(timeIntervalSince1970: 1_790_000_000.7), amount: Money(minorUnits: 1250),
                                      kind: .goalDeposit, categoryID: UUID(), goalID: UUID(), note: "kawa")
        XCTAssertEqual(TransactionEntity(transaction).domain, transaction)
    }

    func testGoalRoundTripKeepsEveryField() {
        let goal = Goal(name: "Wakacje", target: Money(minorUnits: 500_000), deadline: Date(timeIntervalSince1970: 1_800_000_000),
                        initial: Money(minorUnits: 10_000), priority: 2, isArchived: true)
        XCTAssertEqual(GoalEntity(goal).domain, goal)
    }

    func testSettingsRoundTripWithAndWithoutManualCosts() throws {
        let custom = BudgetSettings(baseIncome: Money(minorUnits: 500_000),
                                    shares: try BucketShares(needs: 60, wants: 10, savings: 30),
                                    manualEssentialCosts: Money(minorUnits: 300_000), fundTargetMonths: 5,
                                    openingFundBalance: Money(minorUnits: 100_000))
        XCTAssertEqual(SettingsEntity(custom).domain, custom)
        let withoutManual = BudgetSettings(baseIncome: Money(minorUnits: 100))
        XCTAssertEqual(SettingsEntity(withoutManual).domain, withoutManual)
    }

    func testUpdateOverwritesEntityFromDomain() {
        let entity = CategoryEntity(Category(name: "Stara", symbol: "x", bucket: .needs, isEssential: false, sortOrder: 1))
        let changed = Category(id: entity.id, name: "Nowa", symbol: "y", bucket: .wants, isEssential: true, sortOrder: 2)
        entity.update(from: changed)
        XCTAssertEqual(entity.domain, changed)
    }

    func testUnknownStoredValuesFallBackToSafeDefaults() {
        XCTAssertEqual(CategoryEntity(bucketRaw: "zzz").domain.bucket, .needs)
        XCTAssertEqual(TransactionEntity(kindRaw: "zzz").domain.kind, .expense)
        XCTAssertEqual(SettingsEntity(sharesNeeds: 90, sharesWants: 90, sharesSavings: 90).domain.shares, .standard)
    }

    func testDefaultCategoriesAreThirteenWithUniqueIDsAndOrder() {
        let all = DefaultCategories.all
        XCTAssertEqual(all.count, 13)
        XCTAssertEqual(Set(all.map(\.id)).count, 13)
        XCTAssertEqual(all.map(\.sortOrder), Array(1...13))
    }

    func testDefaultCategoriesSplitEssentialNeedsAndOptionalWants() {
        let all = DefaultCategories.all
        XCTAssertEqual(all.filter { $0.bucket == .needs }.count, 7)
        XCTAssertTrue(all.filter { $0.bucket == .needs }.allSatisfy(\.isEssential))
        XCTAssertEqual(all.filter { $0.bucket == .wants }.count, 6)
        XCTAssertTrue(all.filter { $0.bucket == .wants }.allSatisfy { !$0.isEssential })
        XCTAssertFalse(all.contains { $0.bucket == .savings })
    }
}
