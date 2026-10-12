import Foundation
import MojeFinanseCore

// Mapowanie między encjami SwiftData a typami MojeFinanseCore (jedyne źródło obliczeń).
// Nieznane wartości zapisane jako tekst (np. po przyszłej zmianie schematu) wracają do bezpiecznych
// wartości domyślnych zamiast zatrzymywać aplikację.

extension CategoryEntity {
    convenience init(_ category: Category) {
        self.init(id: category.id, name: category.name, symbol: category.symbol,
                  bucketRaw: category.bucket.rawValue, isEssential: category.isEssential,
                  sortOrder: category.sortOrder, isArchived: category.isArchived)
    }

    var domain: Category {
        Category(id: id, name: name, symbol: symbol, bucket: Bucket(rawValue: bucketRaw) ?? .needs,
                 isEssential: isEssential, sortOrder: sortOrder, isArchived: isArchived)
    }

    func update(from category: Category) {
        name = category.name
        symbol = category.symbol
        bucketRaw = category.bucket.rawValue
        isEssential = category.isEssential
        sortOrder = category.sortOrder
        isArchived = category.isArchived
    }
}

extension TransactionEntity {
    convenience init(_ transaction: Transaction) {
        self.init(id: transaction.id, date: transaction.date, amountMinor: transaction.amount.minorUnits,
                  kindRaw: transaction.kind.rawValue, categoryID: transaction.categoryID,
                  goalID: transaction.goalID, note: transaction.note)
    }

    var domain: Transaction {
        Transaction(id: id, date: date, amount: Money(minorUnits: amountMinor),
                    kind: TransactionKind(rawValue: kindRaw) ?? .expense,
                    categoryID: categoryID, goalID: goalID, note: note)
    }

    func update(from transaction: Transaction) {
        date = transaction.date
        amountMinor = transaction.amount.minorUnits
        kindRaw = transaction.kind.rawValue
        categoryID = transaction.categoryID
        goalID = transaction.goalID
        note = transaction.note
    }
}

extension GoalEntity {
    convenience init(_ goal: Goal) {
        self.init(id: goal.id, name: goal.name, targetMinor: goal.target.minorUnits, deadline: goal.deadline,
                  initialMinor: goal.initial.minorUnits, priority: goal.priority, isArchived: goal.isArchived)
    }

    var domain: Goal {
        Goal(id: id, name: name, target: Money(minorUnits: targetMinor), deadline: deadline,
             initial: Money(minorUnits: initialMinor), priority: priority, isArchived: isArchived)
    }

    func update(from goal: Goal) {
        name = goal.name
        targetMinor = goal.target.minorUnits
        deadline = goal.deadline
        initialMinor = goal.initial.minorUnits
        priority = goal.priority
        isArchived = goal.isArchived
    }
}

extension SettingsEntity {
    convenience init(_ settings: BudgetSettings) {
        self.init(baseIncomeMinor: settings.baseIncome.minorUnits, sharesNeeds: settings.shares.needs,
                  sharesWants: settings.shares.wants, sharesSavings: settings.shares.savings,
                  manualEssentialCostsMinor: settings.manualEssentialCosts?.minorUnits,
                  fundTargetMonths: settings.fundTargetMonths,
                  openingFundBalanceMinor: settings.openingFundBalance.minorUnits)
    }

    var domain: BudgetSettings {
        let shares = (try? BucketShares(needs: sharesNeeds, wants: sharesWants, savings: sharesSavings)) ?? .standard
        return BudgetSettings(baseIncome: Money(minorUnits: baseIncomeMinor), shares: shares,
                              manualEssentialCosts: manualEssentialCostsMinor.map { Money(minorUnits: $0) },
                              fundTargetMonths: fundTargetMonths,
                              openingFundBalance: Money(minorUnits: openingFundBalanceMinor))
    }

    func update(from settings: BudgetSettings) {
        baseIncomeMinor = settings.baseIncome.minorUnits
        sharesNeeds = settings.shares.needs
        sharesWants = settings.shares.wants
        sharesSavings = settings.shares.savings
        manualEssentialCostsMinor = settings.manualEssentialCosts?.minorUnits
        fundTargetMonths = settings.fundTargetMonths
        openingFundBalanceMinor = settings.openingFundBalance.minorUnits
    }
}
