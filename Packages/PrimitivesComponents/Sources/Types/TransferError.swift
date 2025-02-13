import Foundation
import Primitives
import Localization

public enum TransferError: LocalizedError {
    case invalidAmount
    case minimumAmount(string: String)
    case invalidAddress(asset: Asset)
    
    public var errorDescription: String? {
        switch self {
        case .invalidAmount:
            Localized.Errors.invalidAmount
        case .minimumAmount(let string):
            Localized.Transfer.minimumAmount(string)
        case .invalidAddress(let asset):
            Localized.Errors.invalidAssetAddress(asset.name)
        }
    }
}
