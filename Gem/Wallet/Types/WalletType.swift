import Foundation
import Primitives

enum ImportWalletType: Hashable {
    case multicoin
    case chain(Chain)
}
