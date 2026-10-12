# Discovery – runda 1: PM

Status: pytania blokujące planowanie zamknięte (15 z 15). Pozostałe 51 pytań [WAŻNE] i [PÓŹNIEJ] czeka na kolejne rundy. Uzupełnia logi finansów osobistych, analityka i projektanta UX/UI.

## Potwierdzone decyzje
| ID | Decyzja |
|----|---------|
| T1 | Stałe okna w tygodniu (np. dwa wieczory + weekend), ok. 10–20 godz. |
| T2 | Jedna sesja zatwierdzania tygodniowo z paczką ID; brak odpowiedzi oznacza brak zgody (agenci czekają) |
| H1 | Bez sztywnej daty; orientacyjna wycena po 2–3 tygodniach pracy, gdy znane jest tempo |
| H2 | Stały czas, zmienny zakres: tniemy wg listy cięć |
| Z1 | Rdzeń MVP: wpisy + budżet → fundusz → cele. Kolejność cięcia: przypomnienie, potem kalkulatory depozytów, potem część kart edukacyjnych |
| Z2 | Kalkulatory w etapie 1: tylko fundusz awaryjny i plan celu (na własnych danych). Procent składany/inflacja i depozyty z podatkiem Belki poza etapem 1 |
| Z3 | Eksport JSON+CSV bez importu, komunikat „to nie kopia zapasowa”; import jako pierwsza pozycja etapu 2 |
| E1 | Trzy etapy: 1 MVP (TestFlight), 2 symulatory inwestycyjne + premiera publiczna, 3 płatności (własna bramka) |
| E2 | „Gotowe” etapu 1: ścieżka onboarding → pierwszy cel bez błędów; wydatek w ≤3 dotknięcia; obliczenia z testami jednostkowymi; fakty z datą weryfikacji; przywracanie danych z kopii na drugim urządzeniu; zero znanych błędów utraty danych |
| R1 | Konto Apple Developer: rejestracja przed pierwszym plastrem technicznym kopii zapasowej |
| A1 | Najpierw krótki spike techniczny kopii zapasowej/przywracania w SwiftData; decyzja po wynikach |
| K1 | Pierwszy cienki pionowy plaster: wpis wydatku → budżet → zapis, z kopią zapasową |
| F1 | Fakty: źródło pierwotne + data weryfikacji w pliku konfiguracji; agent przygotowuje, właściciel zatwierdza |
| F2 | W treściach dozwolone nazwy kategorii (obligacje skarbowe, IKE, ETF); niedozwolone konkretne serie, fundusze, instytucje |
| Q1 | Testuje tylko właściciel w etapie 1 |

## Zmiany względem wcześniejszych ustaleń
- **Z2 zmienia I1** (finanse osobiste): z kalkulatorów MVP wypadają procent składany/inflacja oraz konto/lokata/obligacje z podatkiem Belki. Trzy scenariusze (I2, I3, KA2, KA3) i podatek Belki (G1) przesuwają się razem z nimi do etapu poza 1; w MVP scenariusze dotyczą co najwyżej planu celu z opcjonalnym oprocentowaniem (E3), do potwierdzenia.
- **Z3 doprecyzowuje LO2:** eksport nie jest kopią zapasową; kopią jest iCloud (A1).
- **K1 + A1:** pierwszy plaster obejmuje spike kopii zapasowej, więc konto Developer musi być założone przed nim (R1).

## Ryzyka (zaakceptowane przez zapis, do monitorowania)
- **Q1: brak testerów poza właścicielem.** Etap 1 nie da walidacji z użytkownikami, a hipotezy o grupie (B1, PER-1/2) pozostają niezweryfikowane. Koliduje z kryterium sukcesu CEL-2 i planem wywiadów. Do ponownej decyzji przed publicznym TestFlight.
- Jedna osoba na kod, projekt, treści, weryfikację faktów i wsparcie; wycena dopiero po 2–3 tygodniach pomiaru tempa.
- Brak konsultacji prawnej (J1) i samodzielna polityka prywatności (PRV-2).
- Mechanizm kopii zapasowej niewybrany (A1), konto Developer niezałożone (R1, ZAS-4).
- Nazwa robocza: sprawdzenie dostępności przed rejestracją aplikacji i bundle ID (WYD-2, R5).

## Do przekazania architektowi
A1 (spike kopii), A2 (konkretna minimalna wersja iOS i zgodność z SwiftData), A3 (model danych: kwoty, flaga „niezbędny”, migracje), A4 (format pliku faktów zmiennych z datą), A5 (testy jednostkowe i zaokrąglenia).
