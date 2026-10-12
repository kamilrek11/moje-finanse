import Foundation

public enum GoalError: Error, Equatable {
    case deadlineNotInFuture
    case noContribution
}

public enum GoalPlanner {
    /// Saldo celu = kwota początkowa + wpłaty − wypłaty przypisane do tego celu.
    public static func balance(of goal: Goal, transactions: [Transaction]) -> Money {
        var total = goal.initial.minorUnits
        for transaction in transactions where transaction.goalID == goal.id {
            switch transaction.kind {
            case .goalDeposit: total += transaction.amount.minorUnits
            case .goalWithdrawal: total -= transaction.amount.minorUnits
            default: break
            }
        }
        return Money(minorUnits: total)
    }

    /// Miesięczna wpłata potrzebna do terminu; zaokrąglana w górę do grosza.
    /// Pełne miesiące kalendarzowe od `from` do `deadline`. Osiągnięty cel zwraca zero bez względu na termin.
    public static func requiredMonthlyContribution(target: Money, current: Money,
                                                   deadline: Date, from: Date) throws -> Money {
        let remaining = target.minorUnits - current.minorUnits
        if remaining <= 0 { return .zero }
        let start = CalendarMonth(containing: from)
        let end = CalendarMonth(containing: deadline)
        let months = (end.year - start.year) * 12 + (end.month - start.month)
        guard months >= 1 else { throw GoalError.deadlineNotInFuture }
        return Money(minorUnits: (remaining + months - 1) / months)
    }

    /// Liczba miesięcy do osiągnięcia celu przy stałej wpłacie (w górę). Osiągnięty cel zwraca 0.
    public static func monthsToReach(target: Money, current: Money, monthlyContribution: Money) throws -> Int {
        let remaining = target.minorUnits - current.minorUnits
        if remaining <= 0 { return 0 }
        guard monthlyContribution.minorUnits > 0 else { throw GoalError.noContribution }
        return (remaining + monthlyContribution.minorUnits - 1) / monthlyContribution.minorUnits
    }
}
