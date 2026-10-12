import Foundation

public enum TransactionCSV {
    /// UTF-8, separator `;`, data `yyyy-MM-dd` (Europe/Warsaw), kwota z przecinkiem (`12,50`).
    public static func encode(_ transactions: [Transaction], categories: [Category], goals: [Goal]) -> String {
        let categoryNames = Dictionary(categories.map { ($0.id, $0.name) }, uniquingKeysWith: { first, _ in first })
        let goalNames = Dictionary(goals.map { ($0.id, $0.name) }, uniquingKeysWith: { first, _ in first })
        let formatter = DateFormatter()
        formatter.calendar = AppCalendar.calendar
        formatter.timeZone = AppCalendar.calendar.timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        var lines = ["data;typ;kwota;kategoria;cel;notatka"]
        for transaction in transactions {
            let fields = [
                formatter.string(from: transaction.date),
                label(for: transaction.kind),
                amount(transaction.amount),
                transaction.categoryID.flatMap { categoryNames[$0] } ?? "",
                transaction.goalID.flatMap { goalNames[$0] } ?? "",
                transaction.note ?? ""
            ]
            lines.append(fields.map(escape).joined(separator: ";"))
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func label(for kind: TransactionKind) -> String {
        switch kind {
        case .expense: return "wydatek"
        case .income: return "przychód"
        case .fundDeposit: return "wpłata na fundusz"
        case .fundWithdrawal: return "wypłata z funduszu"
        case .goalDeposit: return "wpłata na cel"
        case .goalWithdrawal: return "wypłata z celu"
        }
    }

    private static func amount(_ money: Money) -> String {
        let absolute = money.minorUnits.magnitude
        let fraction = absolute % 100
        return "\(money.minorUnits < 0 ? "-" : "")\(absolute / 100),\(fraction < 10 ? "0" : "")\(fraction)"
    }

    private static func escape(_ field: String) -> String {
        guard field.contains(";") || field.contains("\"") || field.contains("\n") || field.contains("\r") else {
            return field
        }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}

public enum BackupError: Error, Equatable {
    case unsupportedSchemaVersion(Int)
    case amountOutOfRange
    case invalidFundTargetMonths(Int)
}

/// Pełna kopia danych aplikacji w JSON. To eksport, nie kopia zapasowa iCloud.
/// Daty zapisywane są w ISO 8601 z dokładnością do milisekundy.
public struct BackupDocument: Codable, Equatable, Sendable {
    public static let currentSchemaVersion = 1

    public let schemaVersion: Int
    public let exportedAt: Date
    public let settings: BudgetSettings
    public let categories: [Category]
    public let goals: [Goal]
    public let transactions: [Transaction]

    public init(exportedAt: Date = Date(), settings: BudgetSettings, categories: [Category],
                goals: [Goal], transactions: [Transaction]) {
        self.schemaVersion = BackupDocument.currentSchemaVersion
        self.exportedAt = exportedAt
        self.settings = settings
        self.categories = categories
        self.goals = goals
        self.transactions = transactions
    }

    public func encoded() throws -> Data {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(formatter.string(from: date))
        }
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(self)
    }

    /// Wczytuje i waliduje kopię: kwoty muszą mieścić się w 0...`Money.maximum`,
    /// `schemaVersion` w 1...`currentSchemaVersion`, `fundTargetMonths` w 3...6.
    public static func decode(from data: Data) throws -> BackupDocument {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let whole = ISO8601DateFormatter()
        whole.formatOptions = [.withInternetDateTime]
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let text = try decoder.singleValueContainer().decode(String.self)
            guard let date = fractional.date(from: text) ?? whole.date(from: text) else {
                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                                        debugDescription: "Niepoprawna data ISO 8601: \(text)"))
            }
            return date
        }
        let document = try decoder.decode(BackupDocument.self, from: data)
        guard document.schemaVersion >= 1, document.schemaVersion <= currentSchemaVersion else {
            throw BackupError.unsupportedSchemaVersion(document.schemaVersion)
        }
        guard EmergencyFund.allowedMonths.contains(document.settings.fundTargetMonths) else {
            throw BackupError.invalidFundTargetMonths(document.settings.fundTargetMonths)
        }
        try document.validateAmounts()
        return document
    }

    private func validateAmounts() throws {
        var amounts = [settings.baseIncome, settings.openingFundBalance]
        if let manual = settings.manualEssentialCosts { amounts.append(manual) }
        amounts += transactions.map(\.amount)
        amounts += goals.flatMap { [$0.target, $0.initial] }
        let range = 0...Money.maximum.minorUnits
        guard amounts.allSatisfy({ range.contains($0.minorUnits) }) else { throw BackupError.amountOutOfRange }
    }
}
