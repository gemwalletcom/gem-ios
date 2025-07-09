// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import WalletConnectorService
import Primitives
import Localization
import Components
import WalletCore
import class Gemstone.SignMessageDecoder

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
        payload.session.metadata.name
    }
    
    public var appUrl: URL? {
        payload.session.metadata.url.asURL
    }
    
    public var appAssetImage: AssetImage {
        AssetImage(imageURL: connectionViewModel.imageUrl)
    }
    
    var textMessageViewModel: TextMessageViewModel {
        TextMessageViewModel(message: decoder.plainPreview())
    }

    public func signMessage() throws {
        let hash = switch payload.message.signType {
        case .eip712:
            // temporary fix for Hyperliquid 712 encoding issue, it contains not valid Solidity type names like HyperliquidTransaction:ApproveAgent
            EthereumAbi.encodeTyped(messageJson: String(data: payload.message.data, encoding: .utf8) ?? "")
        default:
            decoder.hash()
        }
        let signature = try keystore.sign(hash: hash, wallet: payload.wallet, chain: payload.chain)
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
