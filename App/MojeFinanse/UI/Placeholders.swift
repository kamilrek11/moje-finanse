import SwiftUI

/// Tymczasowy ekran dla zakładek, których zawartość powstaje w kolejnych taskach.
struct TabPlaceholder: View {
    let title: String

    var body: some View {
        NavigationStack {
            ContentUnavailableView(title, systemImage: "hammer", description: Text(Copy.pl.placeholderMessage))
                .navigationTitle(title)
        }
    }
}

struct AddEntryPlaceholder: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView(Copy.pl.newEntryTitle, systemImage: "plus.circle",
                                   description: Text(Copy.pl.placeholderMessage))
                .navigationTitle(Copy.pl.newEntryTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(Copy.pl.cancel) { dismiss() }
                    }
                }
        }
    }
}
