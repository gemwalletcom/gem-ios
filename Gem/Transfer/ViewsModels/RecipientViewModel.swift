import Foundation
import Primitives
import Keystore
import Blockchain
import GemstonePrimitives

//enum RecipientAddressType {
//    case wallets
//    case view
//}
//
//struct RecipientViewModel {
//    let wallet: Wallet
//    
//    private let keystore: any Keystore
//    private let walletsService: WalletsService
//    private let assetModel: AssetViewModel
//    
//    init(wallet: Wallet, keystore: any Keystore, walletsService: WalletsService, assetModel: AssetViewModel) {
//        self.wallet = wallet
//        self.keystore = keystore
//        self.walletsService = walletsService
//        self.assetModel = assetModel
//    }
//    
//    var asset: Asset {
//        return assetModel.asset
//    }
//    
//    var tittle: String {
//        return Localized.Transfer.Recipient.title
//    }
//    
//    var recipientField: String {
//        return Localized.Transfer.Recipient.addressField
//    }
//    
//    var memoField: String {
//        return Localized.Transfer.memo
//    }
//    
//    func isValidAddress(address: String) -> Bool {
//        return asset.chain.isValidAddress(address)
//    }
//    
//    var showMemo: Bool {
//        return assetModel.supportMemo
//    }
//    
//    func getRecipientData(
//        asset: Asset,
//        recipient: Recipient
//    ) throws -> AmountRecipientData {
//        guard isValidAddress(address: recipient.address) else {
//            throw TransferError.invalidAddress(asset: asset)
//        }
//        
//        return AmountRecipientData(
//            type: .transfer,
//            data: RecipientData(
//                asset: asset,
//                recipient: recipient
//            )
//        )
//    }
//    
//    func getRecipient(by type: RecipientAddressType) -> [RecipientAddress] {
//        switch type {
//        case .wallets:
//            return keystore.wallets
//                .filter { ($0.type == .multicoin || $0.type == .single) && $0.id != wallet.id }
//                .filter { $0.accounts.first(where: { $0.chain == asset.chain }) != nil }
//                .map {
//                    return RecipientAddress(
//                        name: $0.name,
//                        address: $0.accounts.first(where: { $0.chain == asset.chain })!.address
//                    )
//            }.compactMap { $0 }
//        case .view:
//            return keystore.wallets.filter { $0.type == .view }.filter { $0.accounts[0].chain == asset.chain}.map {
//                return RecipientAddress(
//                    name: $0.name,
//                    address: $0.accounts[0].address
//                )
//            }
//        }
//    }
//}
//
//extension RecipientViewModel: Hashable {
//    static func == (lhs: RecipientViewModel, rhs: RecipientViewModel) -> Bool {
//        return lhs.wallet.id == rhs.wallet.id && lhs.asset == rhs.asset
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(wallet.id)
//    }
//}
