import Foundation
import Style

public protocol AmountDisplayable: Sendable {
    var amount: TextValue { get }
    var fiat: TextValue? { get }
    var showFiat: Bool { get }
}
