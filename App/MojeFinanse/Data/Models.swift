import Foundation
import SwiftData
import MojeFinanseCore

// Modele zgodne z ograniczeniami CloudKit: każda właściwość ma wartość domyślną lub jest opcjonalna,
// brak `@Attribute(.unique)`, brak relacji (powiązania przez UUID jak w typach MojeFinanseCore).
// Kwoty to grosze (Int), wyliczenia robi wyłącznie MojeFinanseCore.

@Model
final class CategoryEntity {
    var id: UUID = UUID()
    var name: String = ""
    var symbol: String = ""
    var bucketRaw: String = Bucket.needs.rawValue
    var isEssential: Bool = false
    var sortOrder: Int = 0
    var isArchived: Bool = false

    init(id: UUID = UUID(), name: String = "", symbol: String = "", bucketRaw: String = Bucket.needs.rawValue,
         isEssential: Bool = false, sortOrder: Int = 0, isArchived: Bool = false) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.bucketRaw = bucketRaw
        self.isEssential = isEssential
        self.sortOrder = sortOrder
        self.isArchived = isArchived
    }
}

@Model
final class TransactionEntity {
    var id: UUID = UUID()
    var date: Date = Date(timeIntervalSince1970: 0)
    var amountMinor: Int = 0
    var kindRaw: String = TransactionKind.expense.rawValue
    var categoryID: UUID?
    var goalID: UUID?
    var note: String?

    init(id: UUID = UUID(), date: Date = Date(timeIntervalSince1970: 0), amountMinor: Int = 0,
         kindRaw: String = TransactionKind.expense.rawValue, categoryID: UUID? = nil,
         goalID: UUID? = nil, note: String? = nil) {
        self.id = id
        self.date = date
        self.amountMinor = amountMinor
        self.kindRaw = kindRaw
        self.categoryID = categoryID
        self.goalID = goalID
        self.note = note
    }
}

@Model
final class GoalEntity {
    var id: UUID = UUID()
    var name: String = ""
    var targetMinor: Int = 0
    var deadline: Date?
    var initialMinor: Int = 0
    var priority: Int = 0
    var isArchived: Bool = false

    init(id: UUID = UUID(), name: String = "", targetMinor: Int = 0, deadline: Date? = nil,
         initialMinor: Int = 0, priority: Int = 0, isArchived: Bool = false) {
        self.id = id
        self.name = name
        self.targetMinor = targetMinor
        self.deadline = deadline
        self.initialMinor = initialMinor
        self.priority = priority
        self.isArchived = isArchived
    }
}

/// Oczekiwany jest dokładnie jeden wiersz ustawień budżetu.
@Model
final class SettingsEntity {
    var id: UUID = UUID()
    var baseIncomeMinor: Int = 0
    var sharesNeeds: Int = 50
    var sharesWants: Int = 30
    var sharesSavings: Int = 20
    var manualEssentialCostsMinor: Int?
    var fundTargetMonths: Int = 3
    var openingFundBalanceMinor: Int = 0

    init(id: UUID = UUID(), baseIncomeMinor: Int = 0, sharesNeeds: Int = 50, sharesWants: Int = 30,
         sharesSavings: Int = 20, manualEssentialCostsMinor: Int? = nil, fundTargetMonths: Int = 3,
         openingFundBalanceMinor: Int = 0) {
        self.id = id
        self.baseIncomeMinor = baseIncomeMinor
        self.sharesNeeds = sharesNeeds
        self.sharesWants = sharesWants
        self.sharesSavings = sharesSavings
        self.manualEssentialCostsMinor = manualEssentialCostsMinor
        self.fundTargetMonths = fundTargetMonths
        self.openingFundBalanceMinor = openingFundBalanceMinor
    }
}

enum MojeFinanseSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] {
        [CategoryEntity.self, TransactionEntity.self, GoalEntity.self, SettingsEntity.self]
    }
}

enum MojeFinanseMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [MojeFinanseSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
