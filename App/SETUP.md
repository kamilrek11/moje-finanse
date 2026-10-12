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
