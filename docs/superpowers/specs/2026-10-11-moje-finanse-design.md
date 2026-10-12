# Moje finanse – specyfikacja projektu (etap 1, MVP)

Data: 2026-10-11. Status: do akceptacji właściciela.
Źródła decyzji: `docs/discovery/runda-1-finanse-osobiste.md`, `runda-1-analityk-biznesowy.md`, `runda-1-projektant-ux-ui.md`, `runda-1-pm.md`. Identyfikatory (np. C2, NFR-3) odsyłają do tych logów.

## 1. Cel i zakres

Natywna aplikacja iOS (SwiftUI) dla początkujących w Polsce (hipoteza: 22–35 lat, pierwsza praca na umowie o pracę, PLN, język polski), która prowadzi ścieżką budżet → fundusz awaryjny → cele → inwestowanie. Cel właściciela: misja edukacyjna (CEL-1). Sukces po 12 miesiącach: stała grupa aktywnych użytkowników i dobre oceny (CEL-2).

Aplikacja edukuje i liczy na danych wpisanych ręcznie. Nie łączy się z bankami, nie wykonuje transakcji, nie udziela doradztwa inwestycyjnego, nie ma backendu, kont ani analityki (K1, MET-1). Płatności są poza zakresem do etapu 3.

### Etapy (E1)
1. **Etap 1 – MVP w TestFlight** (ta specyfikacja).
2. **Etap 2** – symulatory inwestycyjne (IKE/IKZE, PPK, ETF), kalkulatory poza funduszem i celem (procent składany, inflacja, konto/lokata/obligacje z podatkiem Belki), import danych, premiera publiczna w App Store.
3. **Etap 3** – płatności, z własną bramką i warunkami (forma prawna, wymogi Apple).

### Wchodzi do etapu 1
- Onboarding (3–5 ekranów, ok. 2 min): ostrzeżenie prywatności i zastrzeżenie, dochód netto, stałe koszty niezbędne, obecne oszczędności.
- Wpisy: pełne transakcje, szybkie dodawanie (≤3 dotknięcia).
- Budżet 50/30/20 ze zmiennymi proporcjami, miesiąc kalendarzowy.
- Fundusz awaryjny i cele (4 typy: jednorazowy wydatek, wkład własny, emerytura/długi termin, cel bez terminu).
- Kalkulatory: fundusz awaryjny i plan celu (Z2).
- Karty edukacyjne (w tym o produktach z F1: konto i lokata, obligacje skarbowe detaliczne, IKE/IKZE, PPK, ETF), bez symulatorów.
- Eksport JSON i CSV (Z3), tryb lokalny bez iCloud z ostrzeżeniem, kopia zapasowa/przywracanie przez iCloud (NFR-3, mechanizm po spike'u A1).
- Jedno opcjonalne lokalne przypomnienie o wpisach (MO1) – pierwsze do cięcia.

### Poza etapem 1
Synchronizacja wielu urządzeń, iPad i orientacja pozioma, widgety, import, powiadomienia inne niż przypomnienie o wpisach, trzy scenariusze i podatek Belki (przechodzą z kalkulatorami do etapu 2), glosariusz rozbudowany (podpowiedzi minimalne), wersje językowe.

### Kolejność cięcia przy braku czasu (Z1, H2)
Stały czas, zmienny zakres. Odpada w kolejności: przypomnienie → (kalkulatory depozytów, już poza etapem 1) → część kart edukacyjnych. Rdzeń nie do ruszenia: wpisy i budżet → fundusz → cele.

## 2. Zasady produktowe

- **Kolejność ścieżki sugerowana, nie wymuszana** (A2). Fundusz zawsze dostępny; gdy brak kategorii niezbędnych, pole ręcznych miesięcznych kosztów jako zastępnik i link do budżetu (ST1).
- **Budżet:** domyślnie 50/30/20, pola procentowe z podglądem kwot, suma musi wynosić 100% (C1, BU2). Limit na koszyk, kwoty na kategorie opcjonalne (BU3). Przychód: dochód bazowy z onboardingu + opcjonalne wpisy przychodu (BU4).
- **Kategorie:** gotowy zestaw z flagą niezbędne/opcjonalne i przypisaniem do koszyka, pełna edycja (C3). Pojęcia „potrzeby” (koszyk) i „niezbędne” (flaga) pozostają rozdzielone.
- **Koszyk oszczędności:** wpłaty na fundusz i cele liczą się do 20% (TR4). Przekroczenie nie blokuje, tylko informuje (Z10, do potwierdzenia).
- **Fundusz awaryjny:** koszty miesięczne = suma kategorii niezbędnych (D1); liczba miesięcy wybierana segmentem 3–6 z opisem „przykład edukacyjny”, bez słów „zalecamy” (D2, FC1). Obecne oszczędności z onboardingu = saldo początkowe funduszu (Z9). Miejsca przechowywania opisywane neutralnymi kategoriami produktów (D3).
- **Cele:** nazwa, kwota docelowa, termin (opcjonalny), kwota początkowa, priorytet; wpłata wyliczana z terminu albo czas z wpłaty (E2). Oprocentowanie/inflacja jako opcja planu celu (E3), szczegóły w etapie 2.
- **Treści:** karty (tytuł, 3 punkty, przykład, „co dalej”, źródło i data, do ok. 250 słów) (ED1, H1). Fakty zmienne w jednym pliku z wartością, źródłem pierwotnym i datą weryfikacji; aktualizacja z nowym wydaniem (H2, F1). Dozwolone nazwy kategorii produktów, niedozwolone konkretne serie, fundusze i instytucje (F2). Bez rankingów i słów „najlepszy/polecany” (J3). Sugestie personalizowane tylko dla oszczędzania i budżetu, nigdy dla instrumentów (J2).
- **Zastrzeżenia:** raz w onboardingu + etykieta „przykład, nie porada” przy każdym wyniku i karcie produktu (ZA1).
- **Język:** spokojny mentor, zwrot na „Ty” bez form zależnych od płci, komunikaty bez winy z neutralną informacją i propozycją kroku (MA1, MA2, EM1).

## 3. UX

- **Nawigacja:** tab bar Start, Budżet, „+”, Cele, Więcej (NA1). Fundusz w zakładce Cele. Karty edukacyjne, eksport i ustawienia w Więcej.
- **Start:** podsumowanie miesiąca, karta sugerowanego kolejnego kroku, ostatnie transakcje (NA2). Krok ścieżki dotyczy oszczędzania; edukacja o inwestowaniu tylko jako link do kart (Z11, do potwierdzenia).
- **Wpis:** „+” otwiera formularz z klawiaturą kwoty; kwota → kategoria → zapis, data dziś, notatka zwinięta, ostatnio używane kategorie na górze, systemowa klawiatura numeryczna, przecinek i grosze (TR1–TR5). Typy wpisów: wydatek, przychód, wpłata/wypłata fundusz i cel.
- **Budżet:** trzy paski postępu z rozwijaniem do kategorii (BU1).
- **Fundusz:** kwota obecna/docelowa, „pokrywa X miesięcy”, segment 3–6, wyliczona wpłata (FC1). **Cele:** karty z postępem, tworzenie na jednym ekranie z polami opcjonalnymi (FC2).
- **Wygląd:** ciepły, przyjazny, na bazie natywnego iOS; jeden akcent i trzy kolory koszyków wspierane tekstem/ikoną; jasny i ciemny motyw wg systemu; standardowe komponenty SwiftUI + 2–3 własne (pasek koszyków, karta celu, wprowadzanie kwoty) (WI1–WI3, OG1).
- **Dostępność:** Dynamic Type do największych rozmiarów, VoiceOver na kluczowych przepływach (wpis, budżet), kontrast co najmniej AA (DO1).
- **Urządzenia:** iPhone, pion; najnowsza i poprzednia główna wersja iOS (NFR-1, NFR-2).
- **Przekazanie projektu:** specyfikacja tekstowa + szkice ASCII, potem SwiftUI Previews (DP1). Szczegółowe ekrany powstają per plaster, tuż przed implementacją.

## 4. Architektura (podejście A)

Dwie warstwy:

- **`MojeFinanseCore`** – lokalny pakiet Swift, bez zależności od UI, SwiftData i iCloud. Czyste funkcje z danych na wynik.
  - *Pieniądze:* kwoty w groszach (liczby całkowite), jedno miejsce zaokrąglania, formatowanie PLN.
  - *Budżet:* proporcje (suma 100%), koszyki, przychód bazowy + wpisy, miesiąc kalendarzowy, sumy koszyków, wpłaty na fundusz/cele w koszyku oszczędności.
  - *Fundusz awaryjny:* koszty z kategorii niezbędnych lub ręczne, cel w miesiącach, pokrycie, brakująca kwota, wpłata.
  - *Cele:* wpłata z terminu albo czas z wpłaty; wynik albo jawny powód braku wyniku.
  - *Fakty:* model pliku faktów (wartość, źródło, data weryfikacji) i kontrola przeterminowania.
- **Aplikacja iOS (SwiftUI)** – widoki, magazyn SwiftData i mapowanie na typy pakietu, kopia zapasowa i tryb lokalny, eksport, przypomnienie, treści edukacyjne (dane w aplikacji).

Przepływ: widok czyta modele SwiftData → mapuje na typy pakietu → pakiet liczy → widok pokazuje wynik. Obliczeń nie ma w widokach ani w modelach.

### Model danych (SwiftData, kwoty w groszach)
- **Kategoria:** nazwa, symbol, koszyk, flaga „niezbędna”, kolejność, archiwizacja.
- **Wpis:** data, kwota, typ (wydatek, przychód, wpłata na fundusz, wypłata z funduszu, wpłata na cel, wypłata z celu), kategoria (dla wydatków), cel (dla wpłat na cel), notatka opcjonalna.
- **Ustawienia budżetu:** dochód bazowy netto, trzy proporcje, ręczne miesięczne koszty niezbędne, docelowa liczba miesięcy funduszu, saldo początkowe funduszu.
- **Cel:** nazwa, kwota docelowa, termin opcjonalny, kwota początkowa, priorytet, archiwizacja.
- Salda funduszu i celów, pozostałe kwoty w koszykach i pokrycie funduszu są wyliczane z wpisów, nie przechowywane.
- Model zgodny z ograniczeniami CloudKit (wartości domyślne, brak unikalnych kluczy, relacje opcjonalne) niezależnie od wyniku spike'a; schemat wersjonowany od początku.

### Kopia zapasowa i dane (NFR-3, NFR-4, A1)
Kopią zapasową jest iCloud, bez synchronizacji wielu urządzeń w etapie 1. Mechanizm (CloudKit z jednym urządzeniem vs własna kopia magazynu w iCloud Drive) wybieramy po krótkim spike'u technicznym w pierwszym plastrze, po założeniu konta Apple Developer. Bez iCloud aplikacja działa lokalnie z wyraźnym ostrzeżeniem; eksport (JSON+CSV) nie jest kopią zapasową i tak jest opisany (Z3).

### Prywatność
Dane tylko na urządzeniu i w prywatnym iCloud użytkownika; aplikacja niczego sama nie wysyła. Do właściciela trafiają tylko e-maile napisane przez użytkowników do wsparcia (PRV-1). Polityka prywatności, FAQ i adres wsparcia na statycznej stronie (PRV-3, WSP-1).

## 5. Błędy

- **Wejście:** kwota dodatnia i rozsądnie ograniczona, kategoria wymagana dla wydatku, przyszła data oznaczana; komunikat przy polu, bez winy.
- **Obliczenia:** wynik albo jawny powód braku (brak danych, termin w przeszłości, cel nieosiągalny w terminie); widok pokazuje wyjaśnienie.
- **Dane:** nieudany zapis → komunikat z ponowieniem; nic nie znika po cichu.
- **iCloud:** brak konta, wyłączony lub pełny → tryb lokalny z ostrzeżeniem i podpowiedzią eksportu; start nigdy nie jest blokowany.
- **Fakty przeterminowane:** ostrzeżenie przy wartości po upływie daty weryfikacji.

## 6. Testy i definicja „gotowe” (E2)

- **Pakiet (`swift test`, uruchamiane w środowisku agenta):** testy jednostkowe każdego obliczenia, w tym wartości brzegowe (zero, bardzo duże kwoty, zaokrąglanie, proporcje ≠ 100%, termin w przeszłości, brak kosztów niezbędnych).
- **Aplikacja (właściciel w Xcode):** testy migracji schematu, eksportu (CSV, JSON), przywracania kopii na drugim urządzeniu; ręczny przegląd dostępności (Dynamic Type, VoiceOver na wpisie i budżecie); test szybkości wpisu (≤3 dotknięcia).
- **Gotowe do TestFlight:** ścieżka onboarding → pierwszy cel działa bez błędów; typowy wydatek w ≤3 dotknięcia; obliczenia z testami jednostkowymi; fakty z datą weryfikacji; przywracanie danych z kopii na drugim urządzeniu; zero znanych błędów utraty danych.
- Środowisko agenta to Linux: nie buduje aplikacji ani nie uruchamia symulatora; budowanie i testy UI wykonuje właściciel.

## 7. Plan pracy

- **Tryb:** stałe okna 10–20 godz. tygodniowo, jedna sesja zatwierdzania tygodniowo z paczką ID, brak odpowiedzi = brak zgody (T1, T2). Brak sztywnej daty; wycena orientacyjna po 2–3 tygodniach pracy (H1).
- **Kolejność (K1):** (1) konto Apple Developer, (2) cienki plaster: wpis wydatku → budżet → zapis, razem ze spike'iem kopii zapasowej, (3) fundusz, (4) cele, (5) karty edukacyjne, (6) eksport, (7) przypomnienie, jeśli wystarczy czasu.
- **Testerzy:** w etapie 1 testuje tylko właściciel (Q1) – patrz ryzyka.

## 8. Ryzyka

- **Jedna osoba** odpowiada za kod, projekt, treści, weryfikację faktów i wsparcie, przy 10–20 godz. tygodniowo.
- **Brak testerów poza właścicielem (Q1):** brak walidacji z użytkownikami, hipotezy o grupie (B1, PER-1/2) niezweryfikowane, kolizja z CEL-2. Do ponownej decyzji przed publicznym TestFlight; wywiady planuje analityk.
- **Brak konsultacji prawnej (J1)** i samodzielna polityka prywatności/regulamin (PRV-2). Ograniczenie: tylko ogólna edukacja, bez rankingów i nazw konkretnych produktów; bramka rewizji przed premierą publiczną (etap 2).
- **Mechanizm kopii zapasowej niewybrany (A1)**; konto Developer niezałożone (ZAS-4, R1); od niego zależy TestFlight i testy iCloud.
- **Nazwa robocza (WYD-2):** sprawdzenie dostępności (App Store, domena, znaki towarowe) przed rejestracją aplikacji i bundle ID.
- **Błędy w faktach finansowych:** autor jest też weryfikatorem; ograniczenie: źródło pierwotne i data weryfikacji, mało faktów w etapie 1 (F1).

## 9. Otwarte pytania (z wyznaczonym miejscem decyzji)

- Z10: zachowanie przy przekroczeniu 20% koszyka oszczędności (rekomendacja: ostrzeżenie bez blokady).
- Z11: czy karta kolejnego kroku kończy się na oszczędzaniu (rekomendacja: tak).
- BU6: oznaczenie flagi „niezbędny koszt” w kategorii.
- F5: zachowanie po przekroczeniu daty weryfikacji faktu.
- A2–A5 (architekt): konkretne minimalne wersje iOS, szczegóły modelu danych, format pliku faktów, zasady zaokrągleń.
- Kryteria przejścia z etapu 1 do 2 i progi liczbowe CEL-2 (G1, G2).
- Pozostałe pytania [WAŻNE] i [PÓŹNIEJ] z czterech logów wchodzą w kolejne rundy per plaster.

### Decyzje podjęte w planie i po przeglądzie kodu (do potwierdzenia)
- Koszty niezbędne funduszu = większa z wartości: wydatki w kategoriach niezbędnych z poprzedniego miesiąca albo wartość ręczna z onboardingu. Częściowo zapisany miesiąc nie zaniża celu; aby obniżyć cel, użytkownik edytuje wartość ręczną.
- Wypłata z funduszu lub celu zmniejsza jego saldo, ale nie zwiększa przychodu i nie zużywa koszyka. Wydatek w kategorii przypisanej do koszyka oszczędności liczy się do zużycia tego koszyka.
- Domyślna miesięczna wpłata do wyliczeń funduszu = limit koszyka oszczędności (edytowalna); domyślny cel funduszu = 3 miesiące.
- Kopia JSON (`BackupDocument`): daty ISO 8601 z dokładnością do milisekundy; przy wczytaniu walidowane kwoty (0…999 999 999,99 zł), wersja schematu (1…obsługiwana) i liczba miesięcy funduszu (3…6).
- Do Części B (zadania 13 i 17): pole kwoty wpisu odrzuca zero (`Money(parsing:)` je akceptuje, bo 0 zł oszczędności jest poprawne w onboardingu); eksport CSV jako bajty z BOM UTF-8 (Excel inaczej zniekształci polskie znaki).
