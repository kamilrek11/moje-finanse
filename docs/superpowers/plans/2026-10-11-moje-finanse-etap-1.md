# Moje finanse – etap 1 (MVP) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Zbudować etap 1 aplikacji iOS „Moje finanse”: wpisy, budżet 50/30/20, fundusz awaryjny, cele, karty edukacyjne, eksport i kopia zapasowa przez iCloud.

**Architecture:** Dwie warstwy. `MojeFinanseCore` to pakiet Swift z czystą logiką (kwoty, budżet, fundusz, cele, fakty, eksport), testowany `swift test`. Aplikacja SwiftUI zawiera widoki, magazyn SwiftData, kopię zapasową i mapowanie na typy pakietu. Obliczeń nie ma w widokach ani w modelach SwiftData.

**Tech Stack:** Swift, SwiftUI, SwiftData, XCTest, lokalny pakiet SPM. Brak zależności zewnętrznych, brak backendu, brak analityki.

**Spec:** `docs/superpowers/specs/2026-10-11-moje-finanse-design.md` (decyzje: `docs/discovery/runda-1-*.md`).

## Podział na części

- **Część A (Task 1–8):** pakiet `MojeFinanseCore`. Środowisko agenta to Linux; weryfikacja `swift test` tutaj, gdy toolchain jest dostępny (Task 1), w przeciwnym razie na Macu właściciela.
- **Część B (Task 9–17):** aplikacja iOS. Agent pisze kod w `App/`; budowanie, Previews, urządzenie i iCloud weryfikuje właściciel w Xcode. Każdy task kończy się checklistą dla właściciela.

## Global Constraints

- Waluta tylko PLN; kwoty jako `Int` w groszach, jedno miejsce zaokrąglania (`Money.rounded`), zaokrąglenie do grosza „half up” (`Decimal` `.plain`).
- Miesiąc kalendarzowy w strefie `Europe/Warsaw` (NFR-8); proporcje budżetu muszą sumować się do 100%, domyślnie 50/30/20 (C1, BU2).
- Fundusz: cel 3–6 miesięcy (D2); koszty z kategorii niezbędnych, ręczna wartość jako zastępnik (D1, ST1); obecne oszczędności z onboardingu = saldo początkowe funduszu (Z9).
- Wpłaty na fundusz i cele liczą się do koszyka oszczędności (TR4).
- Aplikacja: iPhone, pion; najnowsza i poprzednia główna wersja iOS (konkretne numery ustala spike A1/A2); jasny i ciemny motyw wg systemu; Dynamic Type do największych rozmiarów, VoiceOver na wpisie i budżecie, kontrast AA (DO1).
- Teksty po polsku, zwrot na „Ty” bez form zależnych od płci, bez słów „przekroczyłeś”, „za dużo wydałeś”, „zalecamy”, „najlepszy”, „polecany” (MA2, EM1, J3). Etykieta „przykład, nie porada” przy wynikach i kartach produktów (ZA1).
- Brak telemetrii, brak ruchu sieciowego z aplikacji, wyłącznie dane lokalne i prywatny iCloud (K1, PRV-1).
- Poza etapem 1 (nie implementować): synchronizacja wielu urządzeń, import, oprocentowanie/inflacja w planie celu, procent składany, depozyty, symulatory IKE/IKZE/PPK/ETF, płatności.
- Każda zmiana w `Sources/` ma test w `Tests/`; commit po każdym tasku.

## Review Focus

- **Granica miesiąca:** wpis o 23:59 31. dnia i 00:00 1. dnia (także przy zmianie czasu) trafia do właściwego miesiąca w `Europe/Warsaw` – Task 4.
- **Dochód zero lub nieustawiony:** limity koszyków to 0, bez dzielenia przez zero i bez crasha – Task 3, 4.
- **Cel z terminem w przeszłości lub w bieżącym miesiącu, albo już osiągnięty:** jawny wynik lub błąd, nigdy ujemna/nieskończona wpłata – Task 6.
- **Bardzo duże kwoty i śmieciowe wejście:** `Money(parsing:)` odrzuca ujemne, puste, z literami i powyżej 999 999 999,99 zł; sumy nie przepełniają `Int` – Task 1, 4.
- **Archiwizowana kategoria i wypłaty z funduszu:** wydatki w archiwizowanej kategorii nadal liczą się w historii i w kosztach niezbędnych; wypłata z funduszu/celu zmniejsza saldo, ale nie zwiększa przychodu ani zużycia koszyka – Task 4, 5.

---

## File Structure

```
Packages/MojeFinanseCore/
  Package.swift
  Sources/MojeFinanseCore/
    Money.swift              kwoty, parsowanie, formatowanie, zaokrąglanie
    Domain.swift             Bucket, TransactionKind, Category, Transaction, Goal, BudgetSettings, BucketShares
    AppCalendar.swift        CalendarMonth, kalendarz Europe/Warsaw
    BudgetMath.swift         limity koszyków, podsumowanie miesiąca
    EmergencyFund.swift      koszty niezbędne, saldo, ocena funduszu
    GoalPlanner.swift        wpłata z terminu, czas z wpłaty, saldo celu
    Facts.swift              VerifiedFact, FactsFile, przeterminowanie
    Export.swift             TransactionCSV, BackupDocument
  Tests/MojeFinanseCoreTests/  jeden plik testów na każdy plik źródłowy
App/MojeFinanse/             źródła aplikacji (Część B), projekt Xcode tworzy właściciel
docs/decisions/              wyniki spike'a (Task 10)
```

---

## Część A – MojeFinanseCore

### Task 1: Pakiet, toolchain i `Money`

**Files:**
- Create: `Packages/MojeFinanseCore/Package.swift`, `Sources/MojeFinanseCore/Money.swift`, `Tests/MojeFinanseCoreTests/MoneyTests.swift`, `.gitignore` (`.build/`, `*.xcuserstate`, `.DS_Store`)

**Interfaces:**
- Produces: `public struct Money: Hashable, Comparable, Codable, Sendable { let minorUnits: Int }` z `init(minorUnits: Int)`, `static let zero`, `static let maximum` (= 99_999_999_999 groszy), `init?(parsing: String)`, `static func rounded(_ value: Decimal) -> Money`, `static func +, -`, `func formatted() -> String`.

- [ ] **Step 1: Sprawdź/zainstaluj toolchain.** Uruchom `swift --version`. Jeśli brak, zainstaluj Swift dla Linux x86_64 (swift.org / swiftly), o ile sieć na to pozwala. Jeśli instalacja jest zablokowana, zapisz to w `docs/decisions/toolchain.md` i dalsze `swift test` uruchamia właściciel na Macu.
- [ ] **Step 2: Utwórz `Package.swift`** (swift-tools-version 5.9): produkt biblioteczny `MojeFinanseCore`, cel testowy `MojeFinanseCoreTests`, bez `platforms` i bez zależności.
- [ ] **Step 3: Napisz testy w `MoneyTests.swift`** (muszą nie przejść):
  - `testParsesCommaAndDot`: `Money(parsing: "12,50")?.minorUnits == 1250`, `"12.50"` → 1250, `"7"` → 700, `"0,05"` → 5.
  - `testRejectsInvalid`: `nil` dla `""`, `"-5"`, `"abc"`, `"1,234"` (trzy miejsca), `"1000000000"` (> maksimum).
  - `testRoundsHalfUp`: `Money.rounded(Decimal(string: "0.125")!)` (w złotych) → 13 groszy; `"0.124"` → 12.
  - `testFormatsPln`: `Money(minorUnits: 1234567).formatted() == "12\u{00A0}345,67\u{00A0}zł"`, `Money(minorUnits: 5).formatted() == "0,05\u{00A0}zł"`, `.zero` → `"0,00\u{00A0}zł"`.
- [ ] **Step 4: Uruchom** `swift test --package-path Packages/MojeFinanseCore` – oczekiwane: FAIL (brak `Money`).
- [ ] **Step 5: Zaimplementuj `Money`** w `Money.swift`. Formatowanie bez `NumberFormatter` (niezależne od ustawień regionalnych): grupy tysięcy rozdzielane U+00A0, przecinek dziesiętny, U+00A0 przed „zł”. `rounded` przyjmuje kwotę w złotych jako `Decimal`.
- [ ] **Step 6: Uruchom testy** – oczekiwane: PASS.
- [ ] **Step 7: Commit** `feat(core): Money z parsowaniem, zaokrąglaniem i formatowaniem PLN`.

### Task 2: Typy domenowe i kalendarz

**Files:**
- Create: `Sources/MojeFinanseCore/Domain.swift`, `Sources/MojeFinanseCore/AppCalendar.swift`, `Tests/MojeFinanseCoreTests/DomainTests.swift`

**Interfaces:**
- Consumes: `Money`.
- Produces (wszystkie `public`, `Codable`, `Hashable`, `Sendable`):
  - `enum Bucket: String, CaseIterable { needs, wants, savings }` (kolejność jak w deklaracji).
  - `enum TransactionKind: String { expense, income, fundDeposit, fundWithdrawal, goalDeposit, goalWithdrawal }`.
  - `struct Category: Identifiable { id: UUID; name: String; symbol: String; bucket: Bucket; isEssential: Bool; sortOrder: Int; isArchived: Bool }`.
  - `struct Transaction: Identifiable { id: UUID; date: Date; amount: Money; kind: TransactionKind; categoryID: UUID?; goalID: UUID?; note: String? }`.
  - `struct Goal: Identifiable { id: UUID; name: String; target: Money; deadline: Date?; initial: Money; priority: Int; isArchived: Bool }`.
  - `struct BucketShares: Equatable { needs: Int; wants: Int; savings: Int; init(needs:wants:savings:) throws; static let standard }` – błąd `BudgetError.sharesMustSumTo100`, także dla wartości ujemnych.
  - `struct BudgetSettings { baseIncome: Money; shares: BucketShares; manualEssentialCosts: Money?; fundTargetMonths: Int; openingFundBalance: Money }`.
  - `struct CalendarMonth: Hashable, Comparable { year: Int; month: Int; init(year:month:); init(containing: Date); var interval: DateInterval; func adding(months: Int) -> CalendarMonth }`; `enum AppCalendar { static let calendar: Calendar }` (gregoriański, `Europe/Warsaw`, poniedziałek pierwszym dniem tygodnia).

- [ ] **Step 1: Testy:** `BucketShares.standard == (50,30,20)`; `try BucketShares(needs: 50, wants: 30, savings: 30)` rzuca `sharesMustSumTo100`; `(110,-5,-5)` rzuca; `Transaction` i `BudgetSettings` przechodzą round-trip `JSONEncoder`/`JSONDecoder`; `CalendarMonth(year: 2026, month: 12).adding(months: 1) == CalendarMonth(year: 2027, month: 1)`.
- [ ] **Step 2: Uruchom testy** – FAIL.
- [ ] **Step 3: Zaimplementuj** typy zgodnie z Interfaces.
- [ ] **Step 4: Uruchom testy** – PASS. **Step 5: Commit** `feat(core): typy domenowe i miesiąc kalendarzowy`.

### Task 3: Limity koszyków

**Files:**
- Create: `Sources/MojeFinanseCore/BudgetMath.swift`, `Tests/MojeFinanseCoreTests/BudgetLimitsTests.swift`

**Interfaces:**
- Produces: `public enum BudgetMath { public static func limits(income: Money, shares: BucketShares) -> [Bucket: Money] }` – suma limitów zawsze równa `income` (metoda największej reszty; remisy rozstrzyga kolejność `Bucket.allCases`).

- [ ] **Step 1: Testy:** dochód 5000,00 zł przy 50/30/20 → 2500,00 / 1500,00 / 1000,00; dochód 100,01 zł przy 50/30/20 → suma limitów == 10001 groszy; dochód 0 → wszystkie 0; dochód 1 grosz przy 50/30/20 → suma == 1 (jeden koszyk dostaje grosz, bez dzielenia przez zero).
- [ ] **Step 2: Uruchom** – FAIL. **Step 3: Zaimplementuj** `limits` (arytmetyka całkowita, bez `Double`). **Step 4: Uruchom** – PASS. **Step 5: Commit** `feat(core): limity koszyków 50/30/20`.

### Task 4: Podsumowanie miesiąca

**Files:**
- Modify: `Sources/MojeFinanseCore/BudgetMath.swift`
- Create: `Tests/MojeFinanseCoreTests/BudgetSummaryTests.swift`

**Interfaces:**
- Consumes: `limits`, typy z Task 2.
- Produces: `public struct BucketStatus { bucket: Bucket; limit: Money; spent: Money; remaining: Money }` (`remaining = limit - spent`, może być ujemne); `public struct BudgetSummary { month: CalendarMonth; income: Money; buckets: [BucketStatus] (w kolejności Bucket.allCases); essentialSpent: Money; uncategorized: Money }`; `BudgetMath.summary(settings: BudgetSettings, categories: [Category], transactions: [Transaction], month: CalendarMonth) -> BudgetSummary`.
- Reguły: `income = baseIncome + suma wpisów .income w miesiącu`; `spent` koszyka needs/wants = suma wpisów `.expense` z kategorią tego koszyka (także archiwizowanych); `spent` savings = suma `.fundDeposit` + `.goalDeposit` (wypłaty nie zmniejszają i nie zwiększają niczego w koszyku); `.expense` bez znanej kategorii liczy się w `uncategorized`; `essentialSpent` = wydatki w kategoriach `isEssential`.

- [ ] **Step 1: Testy:** (a) przykładowy miesiąc: dochód 5000 zł, wydatek 1200 zł w kategorii needs/essential, 300 zł w wants, wpłata na fundusz 400 zł → spent 1200/300/400, remaining 1300/1200/600, `essentialSpent == 1200 zł`; (b) wpis `.income` 500 zł zwiększa `income` i limity; (c) wypłata z funduszu 100 zł nie zmienia `savings.spent` ani `income`; (d) wydatek w archiwizowanej kategorii wlicza się; (e) wydatek z nieznanym `categoryID` trafia do `uncategorized`; (f) **granica miesiąca:** wpis z datą 2026-10-31 23:59:59 w `Europe/Warsaw` trafia do października, a wpis 2026-11-01 00:00:00 w `Europe/Warsaw` do listopada; daty zbudowane przez `AppCalendar.calendar`, także dla przełomu 2026-03-28/29 (zmiana czasu) nie przesuwa wpisu do sąsiedniego miesiąca; (g) dochód 0 → limity 0, brak crasha; (h) bardzo duże kwoty (`Money.maximum`) sumowane 2 razy nie przepełniają `Int` na 64-bitowym `Int`.
- [ ] **Step 2–4:** uruchom (FAIL), zaimplementuj `summary`, uruchom (PASS). **Step 5: Commit** `feat(core): podsumowanie miesięcznego budżetu`.

### Task 5: Fundusz awaryjny

**Files:**
- Create: `Sources/MojeFinanseCore/EmergencyFund.swift`, `Tests/MojeFinanseCoreTests/EmergencyFundTests.swift`

**Interfaces:**
- Consumes: typy z Task 2, `BudgetMath.summary`.
- Produces: `public struct FundAssessment { target: Money; balance: Money; shortfall: Money; monthsCovered: Decimal }` (`shortfall` ≥ 0; `monthsCovered` obcięte do jednego miejsca po przecinku); `public enum FundError: Error { noEssentialCosts, targetMonthsOutOfRange }`; `public enum EmergencyFund { static func balance(settings:, transactions:) -> Money; static func monthlyEssentials(settings:, categories:, transactions:, referenceMonth: CalendarMonth) -> Money; static func assess(monthlyEssentials: Money, targetMonths: Int, balance: Money) throws -> FundAssessment }`.
- Reguły: `balance = openingFundBalance + .fundDeposit − .fundWithdrawal` (może być ujemne); `monthlyEssentials` = wydatki w kategoriach niezbędnych w **poprzednim pełnym miesiącu** względem `referenceMonth`; gdy to 0, wartość `manualEssentialCosts` (lub `.zero`) – decyzja planu zgodna z D1/ST1, dopisana do otwartych pytań specyfikacji w Task 17; `assess` rzuca `noEssentialCosts` przy 0 i `targetMonthsOutOfRange` poza 3…6.

- [ ] **Step 1: Testy:** koszty 3000,00 zł, saldo 6000,00 zł, cel 6 → target 18000,00 zł, shortfall 12000,00 zł, `monthsCovered == 2.0`; saldo 20000 zł → shortfall 0, `monthsCovered == 6.6`; koszty 0 → `noEssentialCosts`; cel 2 i 7 → `targetMonthsOutOfRange`; `monthlyEssentials` bierze poprzedni miesiąc, a bez wydatków niezbędnych zwraca ręczną wartość; `balance` uwzględnia wypłatę i saldo początkowe.
- [ ] **Step 2–4:** uruchom (FAIL), zaimplementuj, uruchom (PASS). **Step 5: Commit** `feat(core): ocena funduszu awaryjnego`.

### Task 6: Planowanie celów

**Files:**
- Create: `Sources/MojeFinanseCore/GoalPlanner.swift`, `Tests/MojeFinanseCoreTests/GoalPlannerTests.swift`

**Interfaces:**
- Consumes: `Goal`, `Transaction`, `CalendarMonth`.
- Produces: `public enum GoalError: Error { deadlineNotInFuture, noContribution }`; `public enum GoalPlanner { static func balance(of goal: Goal, transactions: [Transaction]) -> Money; static func requiredMonthlyContribution(target: Money, current: Money, deadline: Date, from: Date) throws -> Money; static func monthsToReach(target: Money, current: Money, monthlyContribution: Money) throws -> Int }`.
- Reguły: liczba miesięcy = pełne miesiące kalendarzowe od `from` do `deadline`, minimum 1; wpłata zaokrąglana w górę do grosza; gdy `current ≥ target`, wpłata 0 i czas 0; `deadline` w miesiącu `from` lub wcześniejszym → `deadlineNotInFuture`; `monthlyContribution ≤ 0` przy brakującej kwocie → `noContribution`; `balance = initial + .goalDeposit − .goalWithdrawal` dla `goalID`.

- [ ] **Step 1: Testy:** cel 12000 zł, bieżąco 0, termin za 12 miesięcy → 1000,00 zł; cel 1000 zł, bieżąco 0, termin za 3 miesiące → 333,34 zł (w górę); `current ≥ target` → 0 niezależnie od terminu (także przy terminie w przeszłości); termin w bieżącym lub przeszłym miesiącu przy brakującej kwocie → `deadlineNotInFuture`; `monthsToReach(target: 1000 zł, current: 0, monthlyContribution: 300 zł) == 4`; wpłata 0 → `noContribution`; saldo celu uwzględnia wypłaty.
- [ ] **Step 2–4:** uruchom (FAIL), zaimplementuj, uruchom (PASS). **Step 5: Commit** `feat(core): planowanie wpłat i czasu dla celów`.

### Task 7: Fakty z datą weryfikacji

**Files:**
- Create: `Sources/MojeFinanseCore/Facts.swift`, `Tests/MojeFinanseCoreTests/FactsTests.swift`

**Interfaces:**
- Produces: `public struct VerifiedFact: Codable, Equatable { key: String; value: String; sourceName: String; sourceURL: URL; verifiedOn: Date; func isStale(asOf: Date, maxAgeDays: Int) -> Bool }`; `public struct FactsFile: Codable { schemaVersion: Int; facts: [VerifiedFact]; static func decode(from: Data) throws -> FactsFile; func fact(for key: String) -> VerifiedFact? }`. Daty w JSON jako `yyyy-MM-dd` (strefa `Europe/Warsaw`).

- [ ] **Step 1: Testy:** dekodowanie przykładowego JSON z jednym faktem; `fact(for:)` zwraca fakt lub `nil`; `isStale` zwraca `false` w dniu granicznym (`maxAgeDays` dni po `verifiedOn`) i `true` dzień później; nieprawidłowa data w JSON rzuca błąd.
- [ ] **Step 2–4:** uruchom (FAIL), zaimplementuj, uruchom (PASS). **Step 5: Commit** `feat(core): format pliku faktów z datą weryfikacji`.

### Task 8: Eksport CSV i kopia JSON

**Files:**
- Create: `Sources/MojeFinanseCore/Export.swift`, `Tests/MojeFinanseCoreTests/ExportTests.swift`

**Interfaces:**
- Produces: `public enum TransactionCSV { static func encode(_ transactions: [Transaction], categories: [Category], goals: [Goal]) -> String }` – UTF-8, separator `;`, nagłówek `data;typ;kwota;kategoria;cel;notatka`, data `yyyy-MM-dd` w `Europe/Warsaw`, kwota z przecinkiem dziesiętnym (`12,50`), pola z `;`, `"` lub nową linią w cudzysłowie z podwojonym `"`; `public struct BackupDocument: Codable { schemaVersion: Int (= 1); exportedAt: Date; settings: BudgetSettings; categories: [Category]; goals: [Goal]; transactions: [Transaction]; func encoded() throws -> Data; static func decode(from: Data) throws -> BackupDocument }` (ISO 8601, klucze posortowane).

- [ ] **Step 1: Testy:** wiersz CSV dla wydatku 12,50 zł w kategorii „Jedzenie” z notatką `kawa; "duża"` → `2026-10-11;wydatek;12,50;Jedzenie;;"kawa; ""duża"""`; wpis bez kategorii i bez celu → puste pola; `BackupDocument` round-trip daje równość wszystkich pól; `decode` odrzuca `schemaVersion` większy niż obsługiwany.
- [ ] **Step 2–4:** uruchom (FAIL), zaimplementuj, uruchom (PASS). **Step 5: Commit** `feat(core): eksport CSV i kopia JSON`.

---

## Część B – Aplikacja iOS

> Właściciel tworzy projekt Xcode (Task 9). Agent pisze źródła w `App/MojeFinanse/` i opisuje, co sprawdzić. Typy z `MojeFinanseCore` są jedynym źródłem obliczeń.

### Task 9: Projekt Xcode, modele SwiftData i kategorie startowe

**Files:**
- Create (właściciel): `App/MojeFinanse.xcodeproj` (iOS App, SwiftUI, tylko iPhone, pion, lokalny pakiet `Packages/MojeFinanseCore`, nazwa robocza, bundle ID po sprawdzeniu nazwy WYD-2/R5).
- Create (agent): `App/MojeFinanse/Data/Models.swift` (`@Model`: `CategoryEntity`, `TransactionEntity`, `GoalEntity`, `SettingsEntity`), `Data/Mapping.swift`, `Data/DefaultCategories.swift`, `MojeFinanseTests/MappingTests.swift`.

**Interfaces:**
- Produces: modele zgodne z CloudKit (wartości domyślne, brak unikalnych kluczy, relacje opcjonalne), `VersionedSchema` v1; mapowanie `entity.domain -> Category/Transaction/Goal/BudgetSettings` i odwrotnie; `DefaultCategories.all: [Category]` – potrzeby/niezbędne: Mieszkanie i czynsz, Rachunki, Jedzenie, Transport, Zdrowie, Ubezpieczenia, Raty; przyjemności/opcjonalne: Restauracje, Rozrywka, Ubrania, Zakupy, Podróże, Subskrypcje (nazwy startowe, edytowalne).

- [ ] Test mapowania w obie strony zachowuje wszystkie pola; zestaw `DefaultCategories.all` ma 13 pozycji i unikalne `id`.
- [ ] Checklista właściciela: projekt buduje się na symulatorze; `MappingTests` przechodzą w Xcode (Cmd+U).
- [ ] Commit `feat(app): projekt Xcode, modele SwiftData i kategorie startowe`.

### Task 10: Spike kopii zapasowej (A1) – wymaga konta Developer

**Files:**
- Create: `docs/decisions/spike-kopia-zapasowa.md` (wynik i datę wpisuje właściciel po teście), prototyp poza gałęzią główną.

- [ ] Właściciel zakłada konto Apple Developer (R1) i włącza iCloud/CloudKit dla bundle ID.
- [ ] Zbadać dwa warianty na fizycznym iPhonie: (1) SwiftData z CloudKit (`ModelConfiguration` z bazą prywatną), (2) własna kopia magazynu do iCloud Drive. Dla każdego: zapis danych, usunięcie aplikacji, reinstalacja, przywrócenie; zachowanie bez iCloud i przy pełnym iCloud.
- [ ] Dokument decyzji: wybrany mechanizm, ograniczenia modelu, konkretne minimalne wersje iOS (A2), koszt utrzymania, ryzyka. Zmiany w modelu z Task 9 wynikające z decyzji w tym samym commicie.
- [ ] Commit `docs: wynik spike'a kopii zapasowej i wybór mechanizmu`.

### Task 11: Szkielet nawigacji i motyw

**Files:** `App/MojeFinanse/App/MojeFinanseApp.swift`, `UI/RootTabView.swift`, `UI/Theme.swift`, `Assets.xcassets` (kolor akcentu, trzy kolory koszyków, jasny/ciemny), `UI/Copy.swift` (wszystkie teksty).

**Interfaces:** `RootTabView` z kartami Start, Budżet, „+”, Cele, Więcej (NA1); `Theme.bucketColor(_: Bucket) -> Color`; `Copy` jako jedyne miejsce tekstów interfejsu.

- [ ] Previews w trybie jasnym, ciemnym i przy największym Dynamic Type. Checklista: „+” pośrodku paska; każdy kolor koszyka ma też etykietę tekstową.
- [ ] Commit `feat(app): nawigacja, motyw i teksty`.

### Task 12: Onboarding (ON1, ON2, ZA1)

**Files:** `UI/Onboarding/OnboardingFlow.swift`, `OnboardingViewModel.swift`, test `OnboardingViewModelTests.swift`.

**Interfaces:** kroki: (1) powitanie z komunikatem „dane tylko u Ciebie” i zastrzeżeniem, (2) dochód netto, (3) stałe koszty niezbędne (→ `manualEssentialCosts`), (4) obecne oszczędności (→ `openingFundBalance`); `OnboardingViewModel.finish() -> BudgetSettings` z proporcjami `standard` i `fundTargetMonths = 3` (dolna granica zakresu 3–6; użytkownik zmienia segmentem w funduszu).

- [ ] Test: poprawne wartości dają `BudgetSettings` z kwotami w groszach; pusty lub niepoprawny dochód blokuje przejście dalej.
- [ ] Checklista: całość mieści się w 3–5 ekranach i ok. 2 minutach; VoiceOver czyta każdy krok.
- [ ] Commit `feat(app): onboarding`.

### Task 13: Dodawanie wpisu (TR1–TR5)

**Files:** `UI/AddTransaction/AddTransactionView.swift`, `AddTransactionViewModel.swift`, test `AddTransactionViewModelTests.swift`.

**Interfaces:** formularz otwierany przez „+”; pole kwoty z fokusem po otwarciu (klawiatura `decimalPad`), potem kategoria (ostatnio używane na górze), zapis; data dziś, notatka zwinięta; przełącznik typu (wydatek, przychód, wpłata/wypłata fundusz i cel); walidacja przez `Money(parsing:)`.

- [ ] Testy modelu widoku: zapis wymaga kwoty i (dla wydatku) kategorii; komunikaty błędów bez winy z `Copy`; kolejność kategorii wg ostatniego użycia.
- [ ] Checklista: od otwarcia aplikacji do zapisu typowego wydatku maks. 3 dotknięcia (TR1).
- [ ] Commit `feat(app): dodawanie wpisów`.

### Task 14: Start i Budżet (NA2, BU1–BU5)

**Files:** `UI/Home/HomeView.swift`, `UI/Budget/BudgetView.swift`, `BudgetSettingsView.swift`, `CategoriesEditorView.swift`, testy widoków modeli.

**Interfaces:** Start: `BudgetSummary` bieżącego miesiąca + karta kolejnego kroku (tylko oszczędzanie, link do kart o inwestowaniu) + ostatnie wpisy. Budżet: trzy paski z rozwijaniem do kategorii, przełączanie miesięcy, edycja proporcji polami procentowymi z podglądem kwot (zapis zablokowany, gdy suma ≠ 100%), edycja kategorii (dodaj, zmień nazwę, flaga „niezbędny koszt”, archiwizacja zamiast usuwania).

- [ ] Komunikat przy zerowym `remaining` i wartościach ujemnych zgodny z EM1.
- [ ] Checklista: VoiceOver na budżecie czyta „koszyk, wydano, zostało”; kontrast AA w obu motywach.
- [ ] Commit `feat(app): ekran Start i Budżet`.

### Task 15: Fundusz awaryjny i Cele (FC1, FC2, ST1)

**Files:** `UI/Goals/GoalsView.swift`, `FundView.swift`, `GoalFormView.swift`, `GoalCard.swift`, testy modeli widoków.

**Interfaces:** zakładka Cele: karta funduszu u góry (kwota obecna/docelowa, „pokrywa X miesięcy”, segment 3–6, wpłata), niżej lista celów. Domyślna miesięczna wpłata do wyliczeń funduszu = limit koszyka oszczędności, edytowalna (decyzja planu do zatwierdzenia przez właściciela). Brak kategorii niezbędnych → pole ręcznych kosztów i link do budżetu (ST1). Formularz celu: nazwa, kwota, termin (opcjonalny), kwota początkowa, priorytet; wpłata z `requiredMonthlyContribution` albo czas z `monthsToReach`; `GoalError` mapowane na teksty z `Copy`.

- [ ] Testy modeli: cel osiągnięty, termin w przeszłości i brak wpłaty pokazują wyjaśnienie, nie błąd techniczny.
- [ ] Commit `feat(app): fundusz awaryjny i cele`.

### Task 16: Karty edukacyjne i fakty (ED1, H1, H2, F1, F2)

**Files:** `Content/cards.json` (karty: tytuł, 3 punkty, przykład, „co dalej”, źródło, data), `Content/facts.json` (`FactsFile`), `UI/Education/CardListView.swift`, `CardView.swift`, `Content/ContentStore.swift`, test `ContentStoreTests.swift`.

**Interfaces:** `ContentStore.cards: [EducationCard]`, `ContentStore.facts: FactsFile`; karta pokazuje źródło i datę weryfikacji oraz etykietę „przykład, nie porada”. Minimalny zestaw kart: budżet 50/30/20, fundusz awaryjny, cele oszczędnościowe, konto oszczędnościowe i lokata, obligacje skarbowe detaliczne, IKE i IKZE, PPK, ETF. Treści pisane z agentem `finanse-osobiste`, każdy fakt z źródła pierwotnego i datą, bez nazw konkretnych serii, funduszy i instytucji (F2).

- [ ] Test: wszystkie karty dekodują się, mają źródło i datę; żadna karta nie zawiera zakazanych słów z Global Constraints.
- [ ] Checklista właściciela: zatwierdzenie merytoryki każdej karty (F1).
- [ ] Commit `feat(app): karty edukacyjne i plik faktów`.

### Task 17: Eksport, tryb lokalny, przypomnienie i bramka TestFlight

**Files:** `UI/More/MoreView.swift`, `ExportView.swift`, `LocalModeBanner.swift`, `Reminders/ReminderScheduler.swift` (cięcie pierwsze, Z1), `docs/superpowers/plans/checklist-testflight.md`; zmiana otwartych pytań w specyfikacji.

**Interfaces:** eksport przez arkusz udostępniania z `TransactionCSV` i `BackupDocument` oraz komunikat „to nie kopia zapasowa” (Z3); baner trybu lokalnego, gdy iCloud niedostępny; lokalne przypomnienie z prośbą o zgodę po pierwszym wpisie.

- [ ] Dopisać do sekcji 9 specyfikacji decyzje podjęte w planie: koszty niezbędne z poprzedniego pełnego miesiąca (Task 5), wypłaty nie zmieniają koszyka (Task 4), domyślna wpłata funduszu = limit koszyka oszczędności (Task 15).
- [ ] Checklista TestFlight (E2): ścieżka onboarding → pierwszy cel bez błędów; wydatek w ≤3 dotknięcia; wszystkie testy Core i aplikacji zielone; fakty z datą weryfikacji; przywracanie danych na drugim urządzeniu; zero znanych błędów utraty danych; przegląd dostępności (Dynamic Type, VoiceOver na wpisie i budżecie).
- [ ] Commit `feat(app): eksport, tryb lokalny, przypomnienie i checklista TestFlight`.
