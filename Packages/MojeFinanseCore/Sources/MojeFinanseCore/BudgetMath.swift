import Foundation

public enum BudgetMath {
    /// Dzieli dochód na koszyki wg proporcji. Suma limitów zawsze równa się dochodowi
    /// (metoda największej reszty; remisy rozstrzyga kolejność `Bucket.allCases`).
    /// Ujemny dochód traktowany jest jak zero.
    public static func limits(income: Money, shares: BucketShares) -> [Bucket: Money] {
        let total = max(income.minorUnits, 0)
        var floors: [Bucket: Int] = [:]
        var remainders: [(bucket: Bucket, remainder: Int)] = []
        for bucket in Bucket.allCases {
            let product = total * shares.percent(for: bucket)
            floors[bucket] = product / 100
            remainders.append((bucket, product % 100))
        }
        var leftover = total - floors.values.reduce(0, +)
        // sort stabilny: przy równych resztach zachowuje kolejność Bucket.allCases
        let order = remainders.enumerated().sorted {
            $0.element.remainder != $1.element.remainder
                ? $0.element.remainder > $1.element.remainder
                : $0.offset < $1.offset
        }
        for entry in order where leftover > 0 {
            floors[entry.element.bucket, default: 0] += 1
            leftover -= 1
        }
        return floors.mapValues { Money(minorUnits: $0) }
    }
}
