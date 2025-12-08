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
        let result = switch Chain(rawValue: payload.message.chain) ?? payload.chain {
        case .sui: try await signSuiMessage()
        case .ton: try await signTonMessage()
        default: try await signDefaultMessage()
        }
        confirmTransferDelegate(.success(result))
    }
}

// MARK: - Signing

extension SignMessageSceneViewModel {
    private func signSuiMessage() async throws -> String {
        var privateKey = try await keystore.getPrivateKey(wallet: payload.wallet, chain: payload.chain)
        defer { privateKey.zeroize() }
        return try CryptoSigner().signSuiPersonalMessage(message: payload.message.data, privateKey: privateKey)
    }

    private func signTonMessage() async throws -> String {
        let hash: Data = decoder.hash()
        async let signature = keystore.sign(hash: hash, wallet: payload.wallet, chain: payload.chain)
        async let publicKey = keystore.getPublicKey(wallet: payload.wallet, chain: payload.chain)
        let domain = payload.session.metadata.url.asURL?.host ?? payload.session.metadata.url
        return try await decoder.getTonResult(signature: signature, publicKey: publicKey, timestamp: Date.timestamp(), domain: domain)
    }

    private func signDefaultMessage() async throws -> String {
        let hash: Data = decoder.hash()
        let signature = try await keystore.sign(hash: hash, wallet: payload.wallet, chain: payload.chain)
        return decoder.getResult(data: signature)
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
