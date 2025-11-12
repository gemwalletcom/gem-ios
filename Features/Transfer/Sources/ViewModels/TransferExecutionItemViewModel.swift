// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components
import Style
import SwiftUI
import GemstonePrimitives
import PrimitivesComponents

public struct TransferExecutionItemViewModel {
    let execution: TransferExecution

    public init(execution: TransferExecution) {
        self.execution = execution
    }

    public var title: String {
        switch execution.state {
        case .executing:
            "Sending..."
        case .success:
            "\(TransferDataViewModel(data: execution.transferData).title) \(Localized.Transaction.Title.sent)"
        case .error:
            "\(TransferDataViewModel(data: execution.transferData).title) \(Localized.Transaction.Status.failed)"
        }
    }

    public var assetImage: AssetImage {
        AssetIdViewModel(assetId: execution.transferData.type.asset.id).assetImage
    }

    public var listItemModel: ListItemModel {
        ListItemModel(
            title: title,
            titleStyle: TextStyle(font: .body, color: titleColor, fontWeight: .semibold),
            imageStyle: ListItemImageStyle(
                assetImage: assetImage,
                imageSize: 40,
                cornerRadiusType: .rounded
            )
        )
    }

    private var titleColor: Color {
        switch execution.state {
        case .executing: Colors.black
        case .success: Colors.green
        case .error: Colors.red
        }
    }
}
