import XCTest
@testable import MojeFinanseCore

final class ExportTests: XCTestCase {
    private func warsaw(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
        AppCalendar.calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    private let food = Category(name: "Jedzenie", symbol: "cart", bucket: .needs, isEssential: true, sortOrder: 0)

    func testCSVHasHeaderAndEscapesNoteWithSeparatorAndQuotes() {
        let transaction = Transaction(date: warsaw(2026, 10, 11), amount: Money(minorUnits: 1250), kind: .expense,
                                      categoryID: food.id, note: "kawa; \"duża\"")
        let csv = TransactionCSV.encode([transaction], categories: [food], goals: [])
        XCTAssertEqual(csv, "data;typ;kwota;kategoria;cel;notatka\n2026-10-11;wydatek;12,50;Jedzenie;;\"kawa; \"\"duża\"\"\"\n")
    }

    func testCSVLeavesCategoryGoalAndNoteEmptyWhenMissing() {
        let transaction = Transaction(date: warsaw(2026, 10, 11), amount: Money(minorUnits: 500_000), kind: .income)
        let csv = TransactionCSV.encode([transaction], categories: [], goals: [])
        XCTAssertTrue(csv.hasSuffix("2026-10-11;przychód;5000,00;;;\n"))
    }

    func testCSVWritesGoalNameAndPolishKindLabels() {
        let goal = Goal(name: "Wakacje", target: Money(minorUnits: 500_000))
        let kinds: [(TransactionKind, String)] = [
            (.expense, "wydatek"), (.income, "przychód"), (.fundDeposit, "wpłata na fundusz"),
            (.fundWithdrawal, "wypłata z funduszu"), (.goalDeposit, "wpłata na cel"), (.goalWithdrawal, "wypłata z celu")
        ]
        for (kind, label) in kinds {
            let row = Transaction(date: warsaw(2026, 10, 11), amount: Money(minorUnits: 100), kind: kind, goalID: goal.id)
            let csv = TransactionCSV.encode([row], categories: [], goals: [goal])
            XCTAssertTrue(csv.hasSuffix("2026-10-11;\(label);1,00;;Wakacje;\n"), label)
        }
    }

    func testCSVUsesWarsawDateNearMidnight() {
        let transaction = Transaction(date: warsaw(2026, 11, 1, 0, 30), amount: Money(minorUnits: 100), kind: .expense)
        XCTAssertTrue(TransactionCSV.encode([transaction], categories: [], goals: []).contains("\n2026-11-01;"))
    }

    func testCSVQuotesNewlinesInNotes() {
        let transaction = Transaction(date: warsaw(2026, 10, 11), amount: Money(minorUnits: 100), kind: .expense,
                                      note: "linia1\nlinia2")
        XCTAssertTrue(TransactionCSV.encode([transaction], categories: [], goals: []).hasSuffix(";\"linia1\nlinia2\"\n"))
    }

    private func sampleBackup() throws -> BackupDocument {
        let goal = Goal(name: "Wakacje", target: Money(minorUnits: 500_000), deadline: warsaw(2027, 6, 1), initial: Money(minorUnits: 10_000), priority: 1)
        let transaction = Transaction(date: warsaw(2026, 10, 11), amount: Money(minorUnits: 1250), kind: .expense,
                                      categoryID: food.id, note: "kawa")
        let settings = BudgetSettings(baseIncome: Money(minorUnits: 500_000), shares: try BucketShares(needs: 60, wants: 10, savings: 30),
                                      manualEssentialCosts: Money(minorUnits: 300_000), fundTargetMonths: 4,
                                      openingFundBalance: Money(minorUnits: 100_000))
        return BackupDocument(exportedAt: warsaw(2026, 10, 12), settings: settings, categories: [food],
                              goals: [goal], transactions: [transaction])
    }

    func testBackupRoundTripKeepsEveryField() throws {
        let original = try sampleBackup()
        let restored = try BackupDocument.decode(from: original.encoded())
        XCTAssertEqual(restored, original)
        XCTAssertEqual(restored.schemaVersion, 1)
    }

    func testBackupJSONIsISO8601WithSortedKeys() throws {
        let json = String(decoding: try sampleBackup().encoded(), as: UTF8.self)
        XCTAssertTrue(json.contains("\"exportedAt\":\"2026-10-12T10:00:00Z\""))
        XCTAssertLessThan(json.range(of: "\"categories\"")!.lowerBound, json.range(of: "\"transactions\"")!.lowerBound)
    }

    func testBackupFromNewerSchemaIsRejected() throws {
        let json = String(decoding: try sampleBackup().encoded(), as: UTF8.self)
            .replacingOccurrences(of: "\"schemaVersion\":1", with: "\"schemaVersion\":2")
        XCTAssertThrowsError(try BackupDocument.decode(from: Data(json.utf8))) {
            XCTAssertEqual($0 as? BackupError, .unsupportedSchemaVersion(2))
        }
    }
}
