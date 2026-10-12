import Foundation

public enum BudgetError: Error, Equatable {
    case sharesMustSumTo100
}

public enum Bucket: String, Codable, Hashable, CaseIterable, Sendable {
    case needs, wants, savings
}

public enum TransactionKind: String, Codable, Hashable, Sendable {
    case expense, income, fundDeposit, fundWithdrawal, goalDeposit, goalWithdrawal
}

public struct Category: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var symbol: String
    public var bucket: Bucket
    public var isEssential: Bool
    public var sortOrder: Int
    public var isArchived: Bool

    public init(id: UUID = UUID(), name: String, symbol: String, bucket: Bucket,
                isEssential: Bool, sortOrder: Int, isArchived: Bool = false) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.bucket = bucket
        self.isEssential = isEssential
        self.sortOrder = sortOrder
        self.isArchived = isArchived
    }
}

public struct Transaction: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var date: Date
    public var amount: Money
    public var kind: TransactionKind
    public var categoryID: UUID?
    public var goalID: UUID?
    public var note: String?

    public init(id: UUID = UUID(), date: Date, amount: Money, kind: TransactionKind,
                categoryID: UUID? = nil, goalID: UUID? = nil, note: String? = nil) {
        self.id = id
        self.date = date
        self.amount = amount
        self.kind = kind
        self.categoryID = categoryID
        self.goalID = goalID
        self.note = note
    }
}

public struct Goal: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var target: Money
    public var deadline: Date?
    public var initial: Money
    public var priority: Int
    public var isArchived: Bool

    public init(id: UUID = UUID(), name: String, target: Money, deadline: Date? = nil,
                initial: Money = .zero, priority: Int = 0, isArchived: Bool = false) {
        self.id = id
        self.name = name
        self.target = target
        self.deadline = deadline
        self.initial = initial
        self.priority = priority
        self.isArchived = isArchived
    }
}

/// Proporcje koszyków w procentach. Suma musi wynosić 100, żadna wartość nie może być ujemna.
public struct BucketShares: Codable, Hashable, Sendable {
    public let needs: Int
    public let wants: Int
    public let savings: Int

    public static let standard = BucketShares(uncheckedNeeds: 50, wants: 30, savings: 20)

    public init(needs: Int, wants: Int, savings: Int) throws {
        guard needs >= 0, wants >= 0, savings >= 0, needs + wants + savings == 100 else {
            throw BudgetError.sharesMustSumTo100
        }
        self.needs = needs
        self.wants = wants
        self.savings = savings
    }

    private init(uncheckedNeeds needs: Int, wants: Int, savings: Int) {
        self.needs = needs
        self.wants = wants
        self.savings = savings
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(needs: container.decode(Int.self, forKey: .needs),
                      wants: container.decode(Int.self, forKey: .wants),
                      savings: container.decode(Int.self, forKey: .savings))
    }

    public func percent(for bucket: Bucket) -> Int {
        switch bucket {
        case .needs: return needs
        case .wants: return wants
        case .savings: return savings
        }
    }
}

public struct BudgetSettings: Codable, Hashable, Sendable {
    public var baseIncome: Money
    public var shares: BucketShares
    public var manualEssentialCosts: Money?
    public var fundTargetMonths: Int
    public var openingFundBalance: Money

    public init(baseIncome: Money, shares: BucketShares = .standard, manualEssentialCosts: Money? = nil,
                fundTargetMonths: Int = 3, openingFundBalance: Money = .zero) {
        self.baseIncome = baseIncome
        self.shares = shares
        self.manualEssentialCosts = manualEssentialCosts
        self.fundTargetMonths = fundTargetMonths
        self.openingFundBalance = openingFundBalance
    }
}
