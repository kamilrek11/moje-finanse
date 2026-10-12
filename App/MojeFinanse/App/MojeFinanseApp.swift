import SwiftUI
import SwiftData

@main
struct MojeFinanseApp: App {
    private let container: Result<ModelContainer, Error> = MojeFinanseApp.makeContainer()

    var body: some Scene {
        WindowGroup {
            switch container {
            case .success(let container):
                RootTabView()
                    .modelContainer(container)
            case .failure:
                StorageErrorView()
            }
        }
    }

    /// Magazyn lokalny (bez CloudKit) do czasu spike'a kopii zapasowej (Task 10).
    /// Nieudane otwarcie nie podstawia pustej bazy w pamięci, bo użytkownik straciłby zapisy po cichu.
    private static func makeContainer() -> Result<ModelContainer, Error> {
        do {
            let schema = Schema(versionedSchema: MojeFinanseSchemaV1.self)
            let configuration = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
            return .success(try ModelContainer(for: schema, migrationPlan: MojeFinanseMigrationPlan.self,
                                               configurations: [configuration]))
        } catch {
            return .failure(error)
        }
    }
}

struct StorageErrorView: View {
    var body: some View {
        ContentUnavailableView(Copy.pl.storageErrorTitle, systemImage: "exclamationmark.triangle",
                               description: Text(Copy.pl.storageErrorMessage))
    }
}
