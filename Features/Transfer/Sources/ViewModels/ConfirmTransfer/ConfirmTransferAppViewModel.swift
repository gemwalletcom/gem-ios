// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Formatters
import Localization
import Primitives
import PrimitivesComponents
import Foundation

public struct ConfirmTransferAppViewModel: ItemModelProvidable {
    private let type: TransferDataType

    init(type: TransferDataType) {
        self.type = type
    }

    var websiteURL: URL? {
        switch type {
        case .transfer,
                .deposit,
                .withdrawal,
                .transferNft,
                .swap,
                .tokenApprove,
                .stake,
                .account,
                .perpetual: .none
        case .generic(_, let metadata, _):
            URL(string: metadata.url)
        }
    }

    var websiteTitle: String { Localized.Settings.website  }
}

// MARK: - ItemModelPrividable

extension ConfirmTransferAppViewModel {
    public var itemModel: ConfirmTransferItemModel {
        guard let name = appValue else { return .empty }

        let subtitle = AppDisplayFormatter.format(
            name: name,
            host: websiteURL?.cleanHost()
        )

        return .app(
            ListItemModel(
                title: Localized.WalletConnect.app,
                subtitle: subtitle,
                imageStyle: ListItemImageStyle.asset(assetImage: appAssetImage)
            )
        )
    }
}

// MARK: - Private

extension ConfirmTransferAppViewModel {
    private var appValue: String? {
        switch type {
        case .transfer,
                .deposit,
                .withdrawal,
                .transferNft,
                .swap,
                .tokenApprove,
                .stake,
                .account,
                .perpetual: .none
        case .generic(_, let metadata, _):
            metadata.shortName
        }
    }

    private var appAssetImage: AssetImage? {
        switch type {
        case .transfer,
                .deposit,
                .withdrawal,
                .transferNft,
                .swap,
                .tokenApprove,
                .stake,
                .account,
                .perpetual:
                .none
        case let .generic(_, session, _):
            AssetImage(imageURL: session.icon.asURL)
        }
    }
}
