import Foundation
import Primitives
import BigInt

typealias TransferDataAction = ((TransferData) -> Void)?
typealias AmountInputAction = ((AmountInput) -> Void)?

struct Recipient {
    let name: String?
    let address: String
    let memo: String?
}

struct RecipientImport {
    let name: String
    let address: String
}

extension Recipient: Hashable {}

struct RecipientData {
    let asset: Asset
    let recipient: Recipient
}

extension RecipientData: Hashable {}

struct WCTransferData: Identifiable {
    let tranferData: TransferData
    let wallet: Wallet

    var id: String { wallet.id }
}

struct TransferData: Sendable {
    let type: TransferDataType
    let recipientData: RecipientData
    let value: BigInt
    let canChangeValue: Bool
    let ignoreValueCheck: Bool

    init(
        type: TransferDataType,
        recipientData: RecipientData,
        value: BigInt,
        canChangeValue: Bool,
        ignoreValueCheck: Bool = false
    ) {
        self.type = type
        self.recipientData = recipientData
        self.value = value
        self.canChangeValue = canChangeValue
        self.ignoreValueCheck = ignoreValueCheck
    }

    func updateValue(_ newValue: BigInt) -> TransferData {
        return TransferData(
            type: type, 
            recipientData: recipientData,
            value: newValue,
            canChangeValue: canChangeValue,
            ignoreValueCheck: ignoreValueCheck
        )
    }
}

extension TransferData: Hashable {}
extension TransferData: Identifiable {
    //FIX: Improve
    var id: String { recipientData.recipient.address }
}

struct TransferDataMetadata {
    let assetBalance: BigInt
    let assetFeeBalance: BigInt
    
    let assetPrice: Price?
    let feePrice: Price?
    
    let assetPrices: [String: Price]
}

extension TransferDataMetadata: Hashable {}
