# Discovery – runda 1: projektant UX/UI

Status: pytania blokujące MVP zamknięte (31 z 31). Pozostałe 110 pytań [WAŻNE] i [PÓŹNIEJ] czeka na kolejne rundy. Uzupełnia logi finansów osobistych i analityka.

## Potwierdzone decyzje
| ID | Decyzja |
|----|---------|
| DP1 | Projekt dostarczany jako specyfikacja tekstowa + szkice ASCII, potem SwiftUI Previews budowane przez implementatora |
| OG1 | Standardowe komponenty SwiftUI + jeden akcent + 2–3 własne komponenty (pasek koszyków, karta celu, kwota) |
| DO1 | Dynamic Type do największych rozmiarów i VoiceOver w kluczowych przepływach; kontrast co najmniej AA |
| WI1 | Nastrój: ciepły i przyjazny, na bazie natywnego iOS |
| WI2 | Jeden kolor akcentu + trzy rozróżnialne kolory koszyków 50/30/20, wspierane tekstem/ikoną |
| WI3 | Jasny i ciemny wg ustawienia systemu, bez własnego przełącznika |
| MA1 | Osobowość: spokojny mentor |
| MA2 | Zwrot na „Ty”, bez form zależnych od płci (styl bezosobowy/rozkazujący); Pan/Pani odpada |
| EM1 | Język bez winy: neutralna informacja z propozycją dalszego kroku; słownik zakazanych wzorców i zamienników przygotuje projektant |
| ZA1 | Zastrzeżenie raz w onboardingu + etykieta „przykład, nie porada” przy każdym wyniku symulacji i karcie produktu |
| TR1 | Cel szybkości: maks. 3 dotknięcia od otwarcia aplikacji do zapisu typowego wydatku |
| TR2 | Przycisk „+” w tab barze; klawiatura z kwotą aktywna od razu |
| TR3 | Pola: kwota → kategoria → zapis; data domyślnie dziś, notatka zwinięta; obowiązkowe kwota i kategoria; ostatnio używane kategorie na górze |
| TR4 | Typy wpisów: wydatek, przychód, wpłata/wypłata fundusz i cel. Wpłaty na fundusz/cele liczone do koszyka oszczędności 20% |
| TR5 | Kwoty w PLN, systemowa klawiatura numeryczna, przecinek i grosze |
| NA1 | Tab bar: Start, Budżet, [+], Cele, Więcej (fundusz awaryjny w zakładce Cele) |
| NA2 | Start: podsumowanie miesiąca + karta sugerowanego kolejnego kroku + ostatnie transakcje |
| BU1 | Budżet: trzy koszyki jako paski postępu z rozwijaniem do kategorii |
| BU2 | Proporcje zmieniane polami procentowymi z podglądem kwot; suma musi być 100% |
| BU3 | Limit na koszyk; kwoty na kategorie opcjonalne |
| BU4 | Stały dochód netto z onboardingu + opcjonalne wpisy dodatkowego przychodu |
| ON1 | Onboarding zbiera: miesięczny dochód netto, obecne oszczędności, stałe koszty niezbędne |
| ON2 | 3–5 ekranów, ok. 2 minut; dalsze dane „po drodze” |
| ST1 | Fundusz zawsze dostępny; gdy brak kategorii niezbędnych, ręczne pole miesięcznych kosztów (wartość początkowa z onboardingu) i link do budżetu |
| FC1 | Ekran funduszu: kwota obecna/docelowa, „pokrywa X miesięcy”, wybór 3–6 mies. segmentem, wyliczona wpłata |
| FC2 | Lista celów jako karty z postępem; tworzenie na jednym ekranie z polami opcjonalnymi |
| KA2 | Trzy scenariusze jako karty jedna pod drugą z zakresem „od–do”, neutralne nazwy i stała kolejność |
| KA3 | Wartości przykładowe z etykietą „przykład”; edytowane zmieniają etykietę na „twój”; „przywróć domyślne”; data weryfikacji faktu w szczegółach |
| ED1 | Karta edukacyjna: jedna przewijana karta (tytuł, 3 punkty, przykład, „co dalej”, źródło i data), do ok. 250 słów |
| MO1 | Jedno opcjonalne lokalne przypomnienie o wpisach; zgoda proszona po pierwszym wpisie |
| LO2 | Eksport: CSV transakcji + JSON pełnej kopii, import w kolejnej wersji |

## Sprzeczności rozstrzygnięte
- **A2 vs D1:** fundusz zawsze dostępny; brakujące koszty niezbędne uzupełnia ręczne pole (ST1).
- **NFR-4 vs NFR-10:** eksport wchodzi do MVP (LO2), import później.
- **„Potrzeby” vs „niezbędne”:** pojęcia pozostają rozdzielone; sposób oznaczenia flagi „niezbędny koszt” w kategorii (BU6) do ustalenia w kolejnej rundzie.

## Do przekazania innym rolom
- finanse-osobiste: BU7 (przeniesienie niewykorzystanych środków), BU9 (komunikat przy kosztach niezbędnych >50%), ON4, FC7, KA7, KA10, ED5, EM4, ZA3 (brzmienie zastrzeżeń), MA4 (słownik terminów).
- analityk: EM7 (weryfikacja tonu), DO7 (testy dostępności), MO5 (kanał opinii), ON6 (dane przykładowe dla testerów).
- architekt: kopia zapasowa w SwiftData (LO2–LO5, NFR-3), NA9 (urządzenia/wersje iOS), TR7, TR10, US3, OG4, KA4 (Swift Charts i dostępność).

## Ryzyka
- 110 pytań [WAŻNE]/[PÓŹNIEJ] otwartych; przy 10–20 godz. tygodniowo trzeba je grupować i wiele zdelegować w formie „rekomendacja projektanta do zatwierdzenia”.
