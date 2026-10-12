import SwiftUI

enum RootTab: Hashable {
    case start, budget, add, goals, more
}

/// Pasek kart: Start, Budżet, „+”, Cele, Więcej (NA1). Środkowy „+” nie jest ekranem:
/// dotknięcie otwiera formularz wpisu, a zaznaczona zakładka wraca do poprzedniej.
struct RootTabView: View {
    @State private var selection: RootTab = .start
    @State private var isAddPresented = false

    private let copy = Copy.pl

    var body: some View {
        TabView(selection: $selection) {
            TabPlaceholder(title: copy.tabStart)
                .tabItem { Label(copy.tabStart, systemImage: "house") }
                .tag(RootTab.start)
            TabPlaceholder(title: copy.tabBudget)
                .tabItem { Label(copy.tabBudget, systemImage: "chart.pie") }
                .tag(RootTab.budget)
            Color.clear
                .tabItem { Label(copy.tabAdd, systemImage: "plus.circle.fill") }
                .accessibilityLabel(copy.addEntryAccessibility)
                .tag(RootTab.add)
            TabPlaceholder(title: copy.tabGoals)
                .tabItem { Label(copy.tabGoals, systemImage: "target") }
                .tag(RootTab.goals)
            TabPlaceholder(title: copy.tabMore)
                .tabItem { Label(copy.tabMore, systemImage: "ellipsis.circle") }
                .tag(RootTab.more)
        }
        .tint(Theme.accent)
        .onChange(of: selection) { oldValue, newValue in
            if newValue == .add {
                selection = oldValue
                isAddPresented = true
            }
        }
        .sheet(isPresented: $isAddPresented) {
            AddEntryPlaceholder()
        }
    }
}

#Preview("Jasny") {
    RootTabView()
}

#Preview("Ciemny, największa czcionka") {
    RootTabView()
        .preferredColorScheme(.dark)
        .environment(\.dynamicTypeSize, .accessibility5)
}
