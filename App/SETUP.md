# Projekt Xcode – kroki dla właściciela (Task 9)

Kod modeli jest gotowy w `App/MojeFinanse/Data/`, a testy w `App/MojeFinanseTests/`. Projekt Xcode zakładasz Ty (agent działa na Linuksie i go nie utworzy).

## 1. Utwórz projekt
1. Xcode → File → New → Project → iOS → **App**.
2. Product Name: `MojeFinanse` (nazwa robocza; bundle ID zmieniasz dopiero po sprawdzeniu nazwy, patrz WYD-2/R5). Interface: **SwiftUI**. Language: Swift. Storage: **None** (SwiftData konfigurujemy sami). Zaznacz **Include Tests**.
3. Zapisz w folderze `moje-finanse/App/` (Xcode utworzy `App/MojeFinanse/MojeFinanse.xcodeproj`). Odznacz „Create Git repository”.
4. Target MojeFinanse → General → **iPhone only**, orientacja tylko Portrait. Minimalna wersja iOS: najnowsza i poprzednia główna (konkretny numer ustali spike z Task 10).
5. Usuń z projektu szablonowe `ContentView.swift`, ewentualny `Item.swift` i szablon testów, jeśli kolidują.

## 2. Dodaj pakiet logiki
File → Add Package Dependencies → Add Local… → wybierz `Packages/MojeFinanseCore` (ścieżka względna `../../Packages/MojeFinanseCore`). Dodaj bibliotekę `MojeFinanseCore` do targetu aplikacji **i** do targetu testów.

## 3. Dodaj gotowe pliki
- Przeciągnij folder `App/MojeFinanse/Data` do grupy projektu (Create groups, **bez** kopiowania plików, target: MojeFinanse).
- Przeciągnij `App/MojeFinanseTests/MappingTests.swift` do targetu testów (nazwa modułu aplikacji musi być `MojeFinanse`, bo test używa `@testable import MojeFinanse`).
- Jeśli Xcode wygenerował własny folder testów, usuń z niego pusty plik szablonowy.

## 4. Zweryfikuj (Cmd+B, Cmd+U)
- [ ] Projekt buduje się na symulatorze iPhone.
- [ ] `MappingTests`: 8 testów przechodzi.
- [ ] Nic w `Data/` nie wymaga zmian, żeby się skompilować. Jeśli Xcode zgłosi błąd w `Models.swift` (SwiftData), wklej mi dokładny komunikat.

Uwaga: te pliki zweryfikowałem tylko na Linuksie w symulacji bez SwiftData (te same pliki bez `@Model`, 8/8 testów). Kompilacja z prawdziwym SwiftData i `VersionedSchema` jest pierwszym punktem do potwierdzenia po Twojej stronie.

---

# Task 11 – nawigacja i motyw

Nowe pliki: `App/MojeFinanse/App/MojeFinanseApp.swift`, `UI/{Copy,Theme,Placeholders,RootTabView}.swift`, katalog kolorów `Theme.xcassets`, test `App/MojeFinanseTests/CopyTests.swift`.

## Dodaj do projektu
1. **Usuń szablonowy `MojeFinanseApp.swift`** (ten, który wygenerował Xcode), bo nowy zawiera `@main`. Dodaj `App/MojeFinanse/App/MojeFinanseApp.swift`.
2. Przeciągnij foldery `App/MojeFinanse/UI` i `Theme.xcassets` do targetu aplikacji (Create groups, bez kopiowania). `Theme.xcassets` jest osobnym katalogiem obok szablonowego `Assets.xcassets` – nie kasuj tamtego.
3. Dodaj `CopyTests.swift` do targetu testów.

## Zweryfikuj (Cmd+B, Cmd+U, Previews)
- [ ] Budowanie bez błędów; `CopyTests` (5) i `MappingTests` (8) przechodzą.
- [ ] Pasek kart: Start, Budżet, „+”, Cele, Więcej. „+” otwiera arkusz „Nowy wpis” i nie zostaje zaznaczony (po zamknięciu zaznaczona jest poprzednia karta).
- [ ] Podglądy `Jasny` i `Ciemny, największa czcionka` pokazują czytelny pasek bez ucięć.
- [ ] VoiceOver czyta środkową kartę jako „Dodaj wpis”.
- [ ] Kolory akcentu i koszyków są czytelne w obu motywach (kontrast wszystkich kolorów ≥ 4,5:1 policzony przy tworzeniu).
- [ ] Uruchomienie na symulatorze nie pokazuje ekranu „Nie udało się otworzyć danych”.

## Co zweryfikowano na Linuksie, a czego nie
Zweryfikowane: logika tekstów i testy `CopyTests` (symulacja), kontrast kolorów (obliczenie). **Niezweryfikowane (wymaga Xcode):** kompilacja SwiftUI/SwiftData, działanie `.onChange` na „+”, wygląd podglądów, `Schema(versionedSchema:)` i `cloudKitDatabase: .none` w `MojeFinanseApp`.
