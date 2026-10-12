import XCTest
import MojeFinanseCore
@testable import MojeFinanse

final class CopyTests: XCTestCase {
    private var allTexts: [String] {
        let fromProperties = Mirror(reflecting: Copy.pl).children.compactMap { $0.value as? String }
        let bucketNames = Bucket.allCases.map { Copy.pl.bucketName($0) }
        return fromProperties + bucketNames
    }

    func testCopyHasTextsAndNoneIsEmpty() {
        XCTAssertGreaterThan(allTexts.count, 10)
        XCTAssertTrue(allTexts.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty })
    }

    func testNoForbiddenPhrasesAppear() {
        let forbidden = ["przekroczyłeś", "przekroczyłaś", "za dużo wydałeś", "za dużo wydałaś",
                         "zalecamy", "najlepszy", "polecany", "polecamy"]
        for text in allTexts {
            for phrase in forbidden {
                XCTAssertFalse(text.lowercased().contains(phrase), "„\(text)” zawiera zakazane „\(phrase)”")
            }
        }
    }

    func testNoGenderedPastTenseForms() {
        for text in allTexts {
            let words = text.lowercased().split { !$0.isLetter }
            XCTAssertFalse(words.contains { $0.hasSuffix("łeś") || $0.hasSuffix("łaś") },
                           "„\(text)” zawiera formę zależną od płci")
        }
    }

    func testTabTitlesAreInTheAgreedOrder() {
        XCTAssertEqual([Copy.pl.tabStart, Copy.pl.tabBudget, Copy.pl.tabGoals, Copy.pl.tabMore],
                       ["Start", "Budżet", "Cele", "Więcej"])
    }

    func testBucketNamesAreDistinctAndPolish() {
        XCTAssertEqual(Bucket.allCases.map { Copy.pl.bucketName($0) }, ["Potrzeby", "Przyjemności", "Oszczędności"])
    }
}
