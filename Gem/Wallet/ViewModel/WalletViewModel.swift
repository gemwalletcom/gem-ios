import Foundation
import Primitives
import Components
import SwiftUI
import Style

struct WalletViewModel {
    let wallet: Wallet
    
    var name: String {
        return wallet.name
    }
    
    var subType: String {
        switch wallet.type {
        case .multicoin:
            return Localized.Wallet.multicoin
        case .view, .single:
            guard let account = wallet.accounts.first else { return "" }
            return AddressFormatter(style: .extra(1), address: account.address, chain: account.chain).value()
        }
    }
    
    var image: Image {
        switch wallet.type {
        case .multicoin:
            return Image(.multicoin)
        case .view, .single:
            let name = wallet.accounts.first?.chain.rawValue ?? ""
            return Image(name)
        }
    }
    
    var subImage: Image? {
        switch wallet.type {
        case .multicoin, .single: .none
        case .view: Image(.glassesRound)
        }
    }
    
    var assetImage: AssetImage {
        AssetImage(
            type: .empty,
            imageURL: .none,
            placeholder: image,
            chainPlaceholder: subImage
        )
    }
}

extension WalletViewModel {
    func isButtonDisabled(type: HeaderButtonType) -> Bool {
        switch type {
        case .send, .swap:
            return wallet.isViewOnly
        case .buy, .receive:
            return false
        }
    }
}

extension WalletViewModel: Identifiable {
    var id: String { wallet.id }
}
