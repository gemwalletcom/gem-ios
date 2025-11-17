// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import WalletConnectorService
import Primitives
import PrimitivesComponents
import Localization
import Components
import class Gemstone.SignMessageDecoder
import class Gemstone.CryptoSigner

@Observable
@MainActor
public final class SignMessageSceneViewModel {
    private let keystore: any Keystore
    private let payload: SignMessagePayload
    private let confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate
    private let decoder: SignMessageDecoder
    
    public var isPresentingUrl: URL? = nil
    public var isPresentingMessage: Bool = false
    
    public init(
        keystore: any Keystore,
        payload: SignMessagePayload,
        confirmTransferDelegate: @escaping TransferDataCallback.ConfirmTransferDelegate
    ) {
        self.keystore = keystore
        self.payload = payload
        self.decoder = SignMessageDecoder(message: payload.message)
        self.confirmTransferDelegate = confirmTransferDelegate
    }
    
    public var networkText: String {
        payload.chain.asset.name
    }

    public var walletText: String {
        payload.wallet.name
    }
    
    public var messageDisplayType: SignMessageDisplayType {
        guard let message = try? decoder.preview() else {
            return .text(decoder.plainPreview())
        }
        return MessagePreviewViewModel(message: message).messageDisplayType
    }
    
    public var buttonTitle: String {
        Localized.Transfer.confirm
    }
    
    public var connectionViewModel: WalletConnectionViewModel {
        WalletConnectionViewModel(connection: WalletConnection(session: payload.session, wallet: payload.wallet))
    }

    public var siweMessageViewModel: SiweMessageViewModel? {
        if case let .siwe(message) = payload.message.signType {
            return SiweMessageViewModel(message: message)
        }
        return nil
    }

    public var appName: String {
        payload.session.metadata.shortName
    }
    
    public var appUrl: URL? {
        payload.session.metadata.url.asURL
    }
    
    public var appAssetImage: AssetImage {
        AssetImage(imageURL: connectionViewModel.imageUrl)
    }
    
    public var appText: String {
        AppDisplayFormatter.format(name: appName, host: connectionViewModel.hostText)
    }
    
    var textMessageViewModel: TextMessageViewModel {
        TextMessageViewModel(message: decoder.plainPreview())
    }

    public func signMessage() async throws {
        let hash: Data = decoder.hash()
        let messageChain = Chain(rawValue: payload.message.chain) ?? payload.chain
        if messageChain == .sui {
            var privateKey = try await keystore.getPrivateKey(wallet: payload.wallet, chain: payload.chain)
            defer { privateKey.zeroize() }
            let signature = try CryptoSigner().signSuiDigest(digest: hash, privateKey: privateKey)
            confirmTransferDelegate(.success(signature))
            return
        }

        let signature = try await keystore.sign(hash: hash, wallet: payload.wallet, chain: payload.chain)
        let result = decoder.getResult(data: signature)
        confirmTransferDelegate(.success(result))
    }
}

// MARK: - Actions

extension SignMessageSceneViewModel {
    public func onViewWebsite() {
        isPresentingUrl = appUrl
    }
    
    public func onViewFullMessage() {
        isPresentingMessage = true
    }
}
