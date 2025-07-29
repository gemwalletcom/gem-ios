// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style

public struct TransactionStateInfoSheetViewModel: InfoSheetModelViewable {
    
    private let imageURL: URL?
    private let placeholder: Image?
    private let state: TransactionState
    
    public init(imageURL: URL?, placeholder: Image?, state: TransactionState) {
        self.imageURL = imageURL
        self.placeholder = placeholder
        self.state = state
    }
    
    public var title: String {
        switch state {
        case .pending: Localized.Transaction.Status.pending
        case .confirmed: Localized.Transaction.Status.confirmed
        case .failed: Localized.Transaction.Status.failed
        case .reverted: Localized.Transaction.Status.reverted
        }
    }
    
    public var description: String {
        switch state {
        case .pending: Localized.Info.Transaction.Pending.description
        case .confirmed: Localized.Info.Transaction.Success.description
        case .failed, .reverted: Localized.Info.Transaction.Error.description
        }
    }
    
    public var image: InfoSheetImage? {
        let stateImage = switch state {
        case .pending: Images.Transaction.State.pending
        case .confirmed: Images.Transaction.State.success
        case .failed, .reverted: Images.Transaction.State.error
        }
        
        return .assetImage(
            AssetImage(
                imageURL: imageURL,
                placeholder: placeholder,
                chainPlaceholder: stateImage
            )
        )
    }
    
    public var button: InfoSheetButton? {
        .url(Docs.url(.transactionStatus))
    }
    
    public var buttonTitle: String {
        Localized.Common.learnMore
    }
}