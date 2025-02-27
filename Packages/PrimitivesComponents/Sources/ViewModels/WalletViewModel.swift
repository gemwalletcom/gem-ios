import Foundation
import Primitives
import Components
import SwiftUI
import Style
import Localization
import FileStore

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
        AssetImage(
            type: wallet.name,
            imageURL: imageUrl(),
            placeholder: avatar(),
            chainPlaceholder: subImage
        )
    }
    
    // MARK: - Private methods
    
    private func imageUrl() -> URL? {
        guard
            let imageUrl = wallet.imageUrl,
            let url = URL(string: imageUrl)
        else {
            return nil
        }
        return url.scheme == nil ? nil : url
    }

    private func avatar() -> Image {
        guard
            let avatarId = wallet.imageUrl,
            let data: Data = try? FileStore().value(for: .avatar(walletId: wallet.id, avatarId: avatarId)),
            let uiImage = UIImage(data: data)
        else {
            return image
        }
        return Image(uiImage: uiImage)
    }
}

extension WalletViewModel: Identifiable, Hashable {
    public var id: String { wallet.id }
}
