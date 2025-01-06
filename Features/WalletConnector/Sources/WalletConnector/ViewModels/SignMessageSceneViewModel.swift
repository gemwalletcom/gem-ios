// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import WalletConnectorService
import Primitives
import Localization

public struct SignMessageSceneViewModel {
    private let keystore: any Keystore
    private let payload: SignMessagePayload
    private let confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate

    public init(
        keystore: any Keystore,
        payload: SignMessagePayload,
        confirmTransferDelegate: @escaping TransferDataCallback.ConfirmTransferDelegate
    ) {
        self.keystore = keystore
        self.payload = payload
        self.confirmTransferDelegate = confirmTransferDelegate
    }

    public var networkText: String {
        payload.chain.asset.name
    }

    public var walletText: String {
        payload.wallet.name
    }

    public var message: String {
        SignMessageDecoder(message: payload.message).preview
    }

    public var buttonTitle: String {
        Localized.Transfer.confirm
    }

    public func signMessage() throws {
        let message = SignMessage(type: payload.message.type, data: payload.message.data)
        let data = try keystore.sign(wallet: payload.wallet, message: message, chain: payload.chain)
        let result = SignMessageDecoder(message: message).getResult(from: data)
        confirmTransferDelegate(.success(result))
    }
}
