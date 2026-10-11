# Discovery – runda 1: analityk biznesowy

Status: pytania blokujące MVP zamknięte (22 z 22). Pytania [WAŻNE] i [PÓŹNIEJ] czekają na kolejne rundy. Uzupełnia `runda-1-finanse-osobiste.md`.

## Potwierdzone decyzje
| ID | Decyzja |
|----|---------|
| CEL-1 | Główny cel: misja edukacyjna (jakość i dostępność treści ważniejsze niż przychód) |
| CEL-2 | Sukces po 12 miesiącach od wydania: stała grupa aktywnych użytkowników i dobre oceny. Progi liczbowe do zaproponowania przez analityka jako hipotezy |
| ZAS-1 | Zespół: tylko właściciel (kod, projekt, treści, weryfikacja faktów) |
| ZAS-2 | 10–20 godzin tygodniowo, termin orientacyjny |
| ZAS-3 | Mac z Xcode i fizyczny iPhone dostępne |
| ZAS-4 | Konto Apple Developer: decyzja otwarta, do rozstrzygnięcia przed TestFlight |
| WYD-1 | Wydawca: osoba prywatna (przy wersji płatnej zweryfikować wymogi Apple wobec sprzedawcy) |
| WYD-2 | „Moje finanse” to nazwa robocza; ostateczną wybrać po sprawdzeniu dostępności (App Store, domena, znaki towarowe) |
| PRV-3 / WSP-1 | Statyczna strona (np. GitHub Pages) z polityką prywatności, FAQ i dedykowanym adresem e-mail wsparcia |
| MOD-1 | MVP tylko w TestFlight; publiczna premiera w App Store po etapie 2 |
| PER-1 / PER-2 | Pierwszy użytkownik: młoda osoba po pierwszej pracy (hipoteza do weryfikacji w wywiadach) |
| MET-1 | Źródła danych o użyciu: App Store Connect, TestFlight, raporty awarii Apple, rozmowy i ankiety. Bez telemetrii |
| NFR-1 | Minimalna wersja iOS: najnowsza i poprzednia główna |
| NFR-2 | Tylko iPhone, orientacja pionowa |
| NFR-3 | Kopia zapasowa i przywracanie przez iCloud, bez synchronizacji wielu urządzeń w MVP |
| NFR-4 | Brak iCloud: pełny tryb lokalny z wyraźnym ostrzeżeniem, plus eksport danych |
| NFR-8 | Okres budżetowy: miesiąc kalendarzowy |
| PRV-1 | Dane trafiające do właściciela: tylko e-maile wysyłane przez użytkowników do wsparcia. Aplikacja nic nie wysyła sama |
| PRV-2 | Politykę prywatności i regulamin przygotowuje właściciel na podstawie wytycznych UODO i Apple; zapisane jako ryzyko |
| REL-1 | Gotowość do TestFlight: pełna ścieżka budżet → fundusz → cel działa, z kalkulatorami i kartami edukacyjnymi |

## Zmiana względem wcześniejszych ustaleń
- **NFR-3 zmienia stos z K1/rundy techniczne:** zamiast pełnej synchronizacji CloudKit między urządzeniami w MVP jest kopia zapasowa/przywracanie przez iCloud. Do potwierdzenia przez architekta, jak to zrealizować w SwiftData (kopia całego magazynu danych vs CloudKit z jednym urządzeniem).
- **NFR-4 + eksport:** tryb lokalny wymaga eksportu danych w MVP (NFR-10, do potwierdzenia).

## Ryzyka
- Jedna osoba odpowiada za kod, projekt, treści i weryfikację faktów finansowych, przy braku konsultacji prawnej (J1) i własnoręcznej polityce prywatności (PRV-2).
- Decyzja o koncie Developer jest otwarta, a od niej zależy TestFlight.
- Nazwa robocza może być zajęta lub kolidować ze znakami towarowymi.

## Do przekazania innym rolom
- finanse-osobiste: PRV-6 (zastrzeżenia), WYD-3/WYD-4 (odpowiedzialność za treści), MOD-5 (afiliacja a neutralność).
- architekt: minimalna wersja SwiftData (NFR-1), realizacja kopii zapasowej (NFR-3).
