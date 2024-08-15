import Foundation
import Primitives

enum TransferError: LocalizedError {
    case invalidAmount
    case minimumAmount(string: String)
    case invalidAddress(asset: Asset)
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return Localized.Errors.invalidAmount
        case .minimumAmount(let string):
            return Localized.Transfer.minimumAmount(string)
        case .invalidAddress(let asset):
            return Localized.Errors.invalidAssetAddress(asset.name)
        }
    }
}
