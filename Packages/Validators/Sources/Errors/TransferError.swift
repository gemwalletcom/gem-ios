import Foundation
import Primitives
import Localization

public enum TransferError: Equatable {
    case invalidAmount
    case minimumAmount(string: String)
    case invalidAddress(asset: Asset)
}

extension TransferError: LocalizedError {
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
