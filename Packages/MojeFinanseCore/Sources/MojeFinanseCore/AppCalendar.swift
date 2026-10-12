import Foundation

public enum AppCalendar {
    /// Kalendarz gregoriański w strefie Europe/Warsaw, tydzień zaczyna się w poniedziałek.
    public static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Warsaw")!
        calendar.firstWeekday = 2
        return calendar
    }()
}

public struct CalendarMonth: Hashable, Comparable, Codable, Sendable {
    public let year: Int
    public let month: Int

    public init(year: Int, month: Int) {
        self.year = year
        self.month = month
    }

    public init(containing date: Date) {
        let parts = AppCalendar.calendar.dateComponents([.year, .month], from: date)
        self.init(year: parts.year!, month: parts.month!)
    }

    public var interval: DateInterval {
        let start = AppCalendar.calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        return AppCalendar.calendar.dateInterval(of: .month, for: start)!
    }

    public func adding(months: Int) -> CalendarMonth {
        let index = year * 12 + (month - 1) + months
        let newYear = Int((Double(index) / 12).rounded(.down))
        return CalendarMonth(year: newYear, month: index - newYear * 12 + 1)
    }

    public static func < (lhs: CalendarMonth, rhs: CalendarMonth) -> Bool {
        (lhs.year, lhs.month) < (rhs.year, rhs.month)
    }
}
