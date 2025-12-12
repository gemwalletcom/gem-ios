// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import WalletConnectorService
import Primitives
import PrimitivesComponents
import Localization
import Components
import class Gemstone.MessageSigner
import GemstonePrimitives

@Observable
@MainActor
public final class SignMessageSceneViewModel {
    private let keystore: any Keystore
    private let payload: SignMessagePayload
    private let confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate
    private let signer: MessageSigner

    public var isPresentingUrl: URL? = nil
    public var isPresentingMessage: Bool = false

    public init(
        keystore: any Keystore,
        payload: SignMessagePayload,
        confirmTransferDelegate: @escaping TransferDataCallback.ConfirmTransferDelegate
    ) {
        self.keystore = keystore
        self.payload = payload
        self.signer = MessageSigner(message: payload.message)
        self.confirmTransferDelegate = confirmTransferDelegate
    }
    
    public var networkText: String {
        payload.chain.asset.name
    }

    public var walletText: String {
        payload.wallet.name
    }
    
    public var messageDisplayType: SignMessageDisplayType {
        guard let message = try? signer.preview() else {
            return .text(signer.plainPreview())
        }
        return MessagePreviewViewModel(message: message).messageDisplayType
    }
    
    public var buttonTitle: String {
        Localized.Transfer.confirm
    }
    
    public var connectionViewModel: WalletConnectionViewModel {
        WalletConnectionViewModel(connection: WalletConnection(session: payload.session, wallet: payload.wallet))
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
        TextMessageViewModel(message: signer.plainPreview())
    }

    public func signMessage() async throws {
        let messageChain = Chain(rawValue: payload.message.chain) ?? payload.chain
        var privateKey = try await keystore.getPrivateKey(wallet: payload.wallet, chain: messageChain)
        defer { privateKey.zeroize() }

        let signature = try signer.sign(privateKey: privateKey)
        confirmTransferDelegate(.success(signature))
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
