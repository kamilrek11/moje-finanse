import Foundation

public enum BudgetMath {
    /// Dzieli dochód na koszyki wg proporcji. Suma limitów zawsze równa się dochodowi
    /// (metoda największej reszty; remisy rozstrzyga kolejność `Bucket.allCases`).
    /// Ujemny dochód traktowany jest jak zero.
    public static func limits(income: Money, shares: BucketShares) -> [Bucket: Money] {
        let total = max(income.minorUnits, 0)
        var floors: [Bucket: Int] = [:]
        var remainders: [(bucket: Bucket, remainder: Int)] = []
        for bucket in Bucket.allCases {
            let product = total * shares.percent(for: bucket)
            floors[bucket] = product / 100
            remainders.append((bucket, product % 100))
        }
        var leftover = total - floors.values.reduce(0, +)
        // sort stabilny: przy równych resztach zachowuje kolejność Bucket.allCases
        let order = remainders.enumerated().sorted {
            $0.element.remainder != $1.element.remainder
                ? $0.element.remainder > $1.element.remainder
                : $0.offset < $1.offset
        }
        for entry in order where leftover > 0 {
            floors[entry.element.bucket, default: 0] += 1
            leftover -= 1
        }
        return floors.mapValues { Money(minorUnits: $0) }
    }
}

public struct BucketStatus: Hashable, Sendable {
    public let bucket: Bucket
    public let limit: Money
    public let spent: Money
    /// `limit - spent`; może być ujemne.
    public let remaining: Money
}

public struct BudgetSummary: Hashable, Sendable {
    public let month: CalendarMonth
    public let income: Money
    public let buckets: [BucketStatus]
    public let essentialSpent: Money
    /// Wydatki, których kategoria nie istnieje (np. po błędzie danych) – nie giną po cichu.
    public let uncategorized: Money
}

extension BudgetMath {
    /// Podsumowanie jednego miesiąca kalendarzowego (Europe/Warsaw).
    /// Wypłaty z funduszu i celów nie zmieniają ani przychodu, ani zużycia koszyków.
    public static func summary(settings: BudgetSettings, categories: [Category],
                               transactions: [Transaction], month: CalendarMonth) -> BudgetSummary {
        let byID = Dictionary(categories.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var extraIncome = 0
        var spent: [Bucket: Int] = [:]
        var essential = 0
        var uncategorized = 0
        for transaction in transactions where CalendarMonth(containing: transaction.date) == month {
            let amount = transaction.amount.minorUnits
            switch transaction.kind {
            case .income:
                extraIncome += amount
            case .expense:
                guard let id = transaction.categoryID, let category = byID[id] else {
                    uncategorized += amount
                    continue
                }
                spent[category.bucket, default: 0] += amount
                if category.isEssential { essential += amount }
            case .fundDeposit, .goalDeposit:
                spent[.savings, default: 0] += amount
            case .fundWithdrawal, .goalWithdrawal:
                break
            }
        }
        let income = Money(minorUnits: settings.baseIncome.minorUnits + extraIncome)
        let limits = limits(income: income, shares: settings.shares)
        let statuses = Bucket.allCases.map { bucket -> BucketStatus in
            let limit = limits[bucket] ?? .zero
            let used = Money(minorUnits: spent[bucket] ?? 0)
            return BucketStatus(bucket: bucket, limit: limit, spent: used, remaining: limit - used)
        }
        return BudgetSummary(month: month, income: income, buckets: statuses,
                             essentialSpent: Money(minorUnits: essential),
                             uncategorized: Money(minorUnits: uncategorized))
    }
}
