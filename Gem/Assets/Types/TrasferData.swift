import Foundation
import Primitives
import BigInt

typealias TransferDataAction = ((TransferData) -> Void)?

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

struct TransferData {
    let type: TransferDataType
    let recipientData: RecipientData
    let value: BigInt
    let canChangeValue: Bool

    func updateValue(_ newValue: BigInt) -> TransferData {
        return TransferData(
            type: type, 
            recipientData: recipientData,
            value: newValue,
            canChangeValue: canChangeValue
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
