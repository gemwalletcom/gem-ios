import Foundation
import Primitives

enum ImportWalletType: Hashable, Sendable {
    case multicoin
    case chain(Chain)
}
