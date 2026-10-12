import Foundation
import MojeFinanseCore

/// Jedyne miejsce tekstów interfejsu. Ton: spokojny mentor, na „Ty”, bez form zależnych od płci,
/// bez słów „przekroczyłeś”, „zalecamy”, „najlepszy”, „polecany” (patrz CopyTests).
struct Copy {
    static let pl = Copy()

    // Zakładki
    let tabStart = "Start"
    let tabBudget = "Budżet"
    let tabAdd = "Dodaj"
    let tabGoals = "Cele"
    let tabMore = "Więcej"
    let addEntryAccessibility = "Dodaj wpis"

    // Dodawanie wpisu (treść formularza: Task 13)
    let newEntryTitle = "Nowy wpis"
    let cancel = "Anuluj"

    // Ekrany jeszcze niezaimplementowane
    let placeholderMessage = "Ten ekran pojawi się w kolejnym kroku budowy aplikacji."

    // Błąd otwarcia danych
    let storageErrorTitle = "Nie udało się otworzyć danych"
    let storageErrorMessage = "Zamknij aplikację i uruchom ją ponownie. Jeśli to się powtórzy, napisz do wsparcia."

    func bucketName(_ bucket: Bucket) -> String {
        switch bucket {
        case .needs: return "Potrzeby"
        case .wants: return "Przyjemności"
        case .savings: return "Oszczędności"
        }
    }
}
