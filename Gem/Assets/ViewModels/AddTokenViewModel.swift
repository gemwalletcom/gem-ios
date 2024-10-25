// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Blockchain
import Components
import Style
import Localization
import ChainService

@Observable
class AddTokenViewModel {
    let service: AddTokenService

    var state: StateViewType<AddAssetViewModel> = .noData
    var input: AddTokenInput

    var isPresentingScanner = false
    var isPresentingSelectNetwork = false

    init(wallet: Wallet, service: AddTokenService) {
        self.service = service
        let chains = wallet.chains(type: .withTokens)
        self.input = AddTokenInput(chains: chains)
    }

    var title: String { Localized.Wallet.AddToken.title }
    var networkTitle: String { Localized.Transfer.network }
    var errorTitle: String { Localized.Errors.errorOccured }
    var actionButtonTitlte: String { Localized.Wallet.Import.action }
    var addressTitleField: String { Localized.Wallet.Import.contractAddressField }

    var pasteImage: Image { Image(systemName: SystemImage.paste) }
    var qrImage: Image { Image(systemName: SystemImage.qrCode) }
    var errorSystemImage: String { SystemImage.errorOccurred }

    var chains: [Chain] { input.chains }

    var addressBinding: Binding<String> {
        Binding(
            get: { [self] in
                self.input.address ?? ""
            },
            set: { [self] in
                self.input.address = $0.isEmpty ? nil : $0
            }
        )
    }
}

// MARK: - Business Logic

extension AddTokenViewModel {
    func fetch() async {
        guard let chain = input.chain, let address = input.address, !address.isEmpty else {
            await MainActor.run { [self] in
                self.state = .noData
            }
            return
        }

        await MainActor.run { [self] in
            self.state = .loading
        }

        do {
            let asset = try await service.getTokenData(chain: chain, tokenId: address)
            await MainActor.run { [self] in
                self.state = .loaded(AddAssetViewModel(asset: asset))
            }
        } catch {
            await MainActor.run { [self] in
                self.state = .error(error)
            }
        }
    }
}

// MARK: - Models extensions

extension TokenValidationError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidTokenId: Localized.Errors.Token.invalidId
        case .invalidMetadata: Localized.Errors.Token.invalidMetadata
        case .other(let error): Localized.Errors.Token.unableFetchTokenInformation(error.localizedDescription)
        }
    }
}
