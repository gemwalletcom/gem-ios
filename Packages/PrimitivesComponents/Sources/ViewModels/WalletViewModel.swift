import Foundation
import Primitives
import Components
import SwiftUI
import Style
import Localization

public struct WalletViewModel {
    public let wallet: Wallet

    public init(wallet: Wallet) {
        self.wallet = wallet
    }

    public var name: String {
        wallet.name
    }

    public var subType: String? {
        switch wallet.type {
        case .multicoin:
            return Localized.Wallet.multicoin
        case .view, .single, .privateKey:
            guard let account = wallet.accounts.first else { return .none }
            return AddressFormatter(style: .extra(1), address: account.address, chain: account.chain).value()
        }
    }
    
    public var image: Image {
        switch wallet.type {
        case .multicoin:
            return Images.Logo.logo
        case .view, .single, .privateKey:
            let name = wallet.accounts.first?.chain.rawValue ?? ""
            return Images.name(name)
        }
    }
    
    public var subImage: Image? {
        switch wallet.type {
        case .multicoin, .single, .privateKey: .none
        case .view: Images.Wallets.watch
        }
    }
    
    public var avatarImage: AssetImage {
        guard let imageUrl = wallet.imageUrl else {
            return AssetImage(
                imageURL: nil,
                placeholder: image,
                chainPlaceholder: subImage
            )
        }
        return AssetImage(
            type: .empty,
            imageURL: URL(string: imageUrl),
            placeholder: nil,
            chainPlaceholder: WalletViewModel(wallet: wallet).subImage
        )
    }
}

extension WalletViewModel: Identifiable, Hashable {
    public var id: String { wallet.id }
}
