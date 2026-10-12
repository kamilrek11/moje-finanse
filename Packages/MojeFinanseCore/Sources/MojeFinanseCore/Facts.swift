import Foundation

/// Fakt zmienny (limit, stawka, parametr) wraz ze źródłem pierwotnym i datą weryfikacji.
public struct VerifiedFact: Codable, Equatable, Sendable {
    public let key: String
    public let value: String
    public let sourceName: String
    public let sourceURL: URL
    public let verifiedOn: Date

    public init(key: String, value: String, sourceName: String, sourceURL: URL, verifiedOn: Date) {
        self.key = key
        self.value = value
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.verifiedOn = verifiedOn
    }

    /// Przeterminowany, gdy od dnia weryfikacji minęło więcej niż `maxAgeDays` pełnych dni (Europe/Warsaw).
    public func isStale(asOf now: Date, maxAgeDays: Int) -> Bool {
        let calendar = AppCalendar.calendar
        let age = calendar.dateComponents([.day], from: calendar.startOfDay(for: verifiedOn),
                                          to: calendar.startOfDay(for: now)).day ?? 0
        return age > maxAgeDays
    }
}

public struct FactsFile: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let facts: [VerifiedFact]

    /// Daty w pliku mają postać `yyyy-MM-dd` (Europe/Warsaw); inny zapis jest błędem.
    public static func decode(from data: Data) throws -> FactsFile {
        let formatter = DateFormatter()
        formatter.calendar = AppCalendar.calendar
        formatter.timeZone = AppCalendar.calendar.timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return try decoder.decode(FactsFile.self, from: data)
    }

    public func fact(for key: String) -> VerifiedFact? {
        facts.first { $0.key == key }
    }
}
