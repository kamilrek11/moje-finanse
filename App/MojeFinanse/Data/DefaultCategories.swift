import Foundation
import MojeFinanseCore

/// Kategorie startowe (nazwy robocze, użytkownik może je edytować). Stałe identyfikatory sprawiają,
/// że ponowne zasianie nie tworzy duplikatów. Wydatki na oszczędności to wpłaty, nie kategorie.
enum DefaultCategories {
    static let all: [Category] = [
        make(1, "Mieszkanie i czynsz", "house", .needs, essential: true),
        make(2, "Rachunki", "bolt", .needs, essential: true),
        make(3, "Jedzenie", "cart", .needs, essential: true),
        make(4, "Transport", "car", .needs, essential: true),
        make(5, "Zdrowie", "cross.case", .needs, essential: true),
        make(6, "Ubezpieczenia", "umbrella", .needs, essential: true),
        make(7, "Raty", "creditcard", .needs, essential: true),
        make(8, "Restauracje", "fork.knife", .wants, essential: false),
        make(9, "Rozrywka", "film", .wants, essential: false),
        make(10, "Ubrania", "tshirt", .wants, essential: false),
        make(11, "Zakupy", "bag", .wants, essential: false),
        make(12, "Podróże", "airplane", .wants, essential: false),
        make(13, "Subskrypcje", "play.rectangle", .wants, essential: false)
    ]

    private static func make(_ number: Int, _ name: String, _ symbol: String, _ bucket: Bucket,
                             essential: Bool) -> Category {
        let id = UUID(uuidString: String(format: "00000000-0000-4000-8000-%012d", number))!
        return Category(id: id, name: name, symbol: symbol, bucket: bucket, isEssential: essential,
                        sortOrder: number)
    }
}
