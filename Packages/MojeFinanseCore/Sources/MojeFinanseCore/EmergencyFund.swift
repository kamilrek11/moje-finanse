import Foundation

public enum FundError: Error, Equatable {
    case noEssentialCosts
    case targetMonthsOutOfRange
}

public struct FundAssessment: Hashable, Sendable {
    public let target: Money
    public let balance: Money
    /// Brakująca kwota, nigdy ujemna.
    public let shortfall: Money
    /// Ile miesięcy kosztów niezbędnych pokrywa saldo, obcięte do jednego miejsca po przecinku (minimum 0).
    public let monthsCovered: Decimal
}

public enum EmergencyFund {
    public static let allowedMonths = 3...6

    /// Saldo = saldo początkowe + wpłaty − wypłaty z funduszu (może być ujemne).
    public static func balance(settings: BudgetSettings, transactions: [Transaction]) -> Money {
        var total = settings.openingFundBalance.minorUnits
        for transaction in transactions {
            switch transaction.kind {
            case .fundDeposit: total += transaction.amount.minorUnits
            case .fundWithdrawal: total -= transaction.amount.minorUnits
            default: break
            }
        }
        return Money(minorUnits: total)
    }

    /// Koszty niezbędne: większa z wartości – wydatki z poprzedniego miesiąca albo wartość ręczna z onboardingu.
    /// Częściowo zapisany miesiąc nie może zaniżyć celu; użytkownik obniża cel, edytując wartość ręczną.
    public static func monthlyEssentials(settings: BudgetSettings, categories: [Category],
                                         transactions: [Transaction], referenceMonth: CalendarMonth) -> Money {
        let previous = referenceMonth.adding(months: -1)
        let fromHistory = BudgetMath.summary(settings: settings, categories: categories,
                                             transactions: transactions, month: previous).essentialSpent
        return max(fromHistory, settings.manualEssentialCosts ?? .zero)
    }

    public static func assess(monthlyEssentials: Money, targetMonths: Int, balance: Money) throws -> FundAssessment {
        guard allowedMonths.contains(targetMonths) else { throw FundError.targetMonthsOutOfRange }
        guard monthlyEssentials > .zero else { throw FundError.noEssentialCosts }
        let target = Money(minorUnits: monthlyEssentials.minorUnits * targetMonths)
        let shortfall = Money(minorUnits: max(target.minorUnits - balance.minorUnits, 0))
        let tenths = balance.minorUnits > 0 ? (balance.minorUnits * 10) / monthlyEssentials.minorUnits : 0
        return FundAssessment(target: target, balance: balance, shortfall: shortfall,
                              monthsCovered: Decimal(tenths) / 10)
    }
}
