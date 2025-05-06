// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import WalletConnectorService
import Primitives
import Localization
import Components
import struct Gemstone.GemEip712Message
import struct Gemstone.GemEip712MessageDomain
import struct Gemstone.GemEip712Field
import enum Gemstone.GemEip712TypedValue

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
    
    public var decoder: SignMessageDecoderDefault {
        SignMessageDecoderDefault(message: payload.message)
    }

    public var networkText: String {
        payload.chain.asset.name
    }

    public var walletText: String {
        payload.wallet.name
    }
    
    public var messageSections: [ListSection<KeyValueItem>]? {
        switch try? decoder.preview {
        case .text(let message): textSection(message)
        case .eip712(let message): eip712Sections(message)
        case .none: nil
        }
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

    public func signMessage() throws {
        let data = try keystore.sign(wallet: payload.wallet, message: payload.message, chain: payload.chain)
        let result = decoder.getResult(from: data)
        confirmTransferDelegate(.success(result))
    }
    
    // MARK: - Private methods
    
    private func textSection(_ message: String) -> [ListSection<KeyValueItem>] {
        [ListSection(
            id: message,
            title: Localized.SignMessage.message,
            image: nil,
            values: [KeyValueItem(title: message, value: .empty)]
        )]
    }
    
    private func eip712Sections(_ message: GemEip712Message) -> [ListSection<KeyValueItem>] {
        [
            ListSection(
                id: message.domain.verifyingContract,
                title: Localized.WalletConnect.domain,
                image: nil,
                values: domainItems(message.domain)
            ),
            ListSection(
                id: Localized.SignMessage.message,
                title: Localized.SignMessage.message,
                image: nil,
                values: eip712Items(message.message)
            )
        ]
    }
    
    private func domainItems(_ domain: GemEip712MessageDomain) -> [KeyValueItem] {
        [
            KeyValueItem(title: Localized.Wallet.name, value: domain.name),
            KeyValueItem(title: Localized.Asset.contract, value: domain.verifyingContract)
        ]
    }
    
    private func eip712Items(_ message: [GemEip712Field]) -> [KeyValueItem] {
        message.flatMap { field in
            messageItems(value: field.value, name: field.name)
        }
    }
    
    private func messageItems(value: GemEip712TypedValue, name: String) -> [KeyValueItem] {
        switch value {
        case .address(let value),
             .uint256(let value),
             .string(let value):
            [KeyValueItem(title: name, value: value)]
        case .bool(let bool):
            [KeyValueItem(title: name, value: bool.description)]
        case .bytes(let data):
            [KeyValueItem(title: name, value: data.base64EncodedString())]
        case .struct(let fields):
            fields.flatMap { messageItems(value: $0.value, name: [name, $0.name].joined(separator: " ")) }
        case .array(let items):
            items.flatMap { messageItems(value: $0, name: name) }
        }
    }
}
