import Foundation
import Primitives
import Localization
import BigInt
import Formatters

public enum TransferError: Equatable {
    case invalidAmount
    case minimumAmount(asset: Asset, required: BigInt)
    case insufficientStakeBalance(total: String, minimum: String, reserved: String)
    case invalidAddress(asset: Asset)
}

extension TransferError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidAmount:
            Localized.Errors.invalidAmount
        case let .minimumAmount(asset, required):
            Localized.Transfer.minimumAmount(
                ValueFormatter(style: .auto).string(required, asset: asset)
            )
        case let .insufficientStakeBalance(total, minimum, reserved):
            "Required balance \(total). Minimum stake \(minimum) + \(reserved) kept on your balance for future network fees."
        case .invalidAddress(let asset):
            Localized.Errors.invalidAssetAddress(asset.name)
        }
    }
}
