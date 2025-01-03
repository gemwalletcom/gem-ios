import Foundation
import Primitives
import Components
import SwiftUI
import Style
import Localization

struct WalletViewModel {
    let wallet: Wallet
    
    var name: String {
        wallet.name
    }
    
    var subType: String? {
        switch wallet.type {
        case .multicoin:
            return Localized.Wallet.multicoin
        case .view, .single, .privateKey:
            guard let account = wallet.accounts.first else { return .none }
            return AddressFormatter(style: .extra(1), address: account.address, chain: account.chain).value()
        }
    }
    
    var image: Image {
        switch wallet.type {
        case .multicoin:
            return Images.Logo.logo
        case .view, .single, .privateKey:
            let name = wallet.accounts.first?.chain.rawValue ?? ""
            return Images.name(name)
        }
    }
    
    var subImage: Image? {
        switch wallet.type {
        case .multicoin, .single, .privateKey: .none
        case .view: Images.Wallets.watch
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

extension WalletViewModel: Identifiable, Hashable {
    var id: String { wallet.id }
}
