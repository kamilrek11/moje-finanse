import SwiftUI
import MojeFinanseCore

/// Kolory pochodzą z katalogu `Theme.xcassets` (jasny i ciemny wariant). Kolor nigdy nie jest jedynym
/// nośnikiem informacji: każdy koszyk ma też nazwę (Copy) i symbol (`bucketSymbol`).
enum Theme {
    static let accent = Color("BrandAccent")

    static func bucketColor(_ bucket: Bucket) -> Color {
        switch bucket {
        case .needs: return Color("BucketNeeds")
        case .wants: return Color("BucketWants")
        case .savings: return Color("BucketSavings")
        }
    }

    static func bucketSymbol(_ bucket: Bucket) -> String {
        switch bucket {
        case .needs: return "house.fill"
        case .wants: return "sparkles"
        case .savings: return "banknote.fill"
        }
    }
}
