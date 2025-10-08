// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Localization
import Primitives
import PrimitivesComponents
import Style

struct TransactionSwapHashViewModel: ItemModelProvidable {
    enum Kind {
        case source(state: TransactionState, infoAction: VoidAction)
        case destination
    }

    private let kind: Kind
    private let hash: String?

    init(kind: Kind, hash: String?) {
        self.kind = kind
        self.hash = hash
    }

    private var title: String {
        switch kind {
        case .source: return Localized.Transaction.sourceTransaction
        case .destination: return Localized.Transaction.destinationTransaction
        }
    }

    private var stateViewModel: TransactionStateViewModel? {
        guard case let .source(state, _) = kind else { return nil }
        return TransactionStateViewModel(state: state)
    }

    private var titleTagType: TitleTagType {
        guard case let .source(state, _) = kind else { return .none }
        switch state {
        case .pending: return .progressView()
        case .confirmed, .failed, .reverted: return .image(stateViewModel?.stateImage ?? Images.Transaction.State.success)
        }
    }

    private var titleExtra: String? {
        stateViewModel?.title
    }

    private var subtitle: String {
        if let hash, hash.isEmpty == false {
            return hash
        }
        return Localized.Transaction.Status.pending
    }

    private var subtitleStyle: TextStyle {
        if let hash, hash.isEmpty == false {
            return TextStyle(font: .callout, color: Colors.black)
        }
        return TextStyle(font: .callout, color: Colors.orange)
    }

    private var infoAction: VoidAction {
        switch kind {
        case let .source(_, action): return action
        case .destination: return nil
        }
    }

    var itemModel: TransactionItemModel {
        .listItem(ListItemModel(
            title: title,
            titleTagType: titleTagType,
            titleExtra: titleExtra,
            subtitle: subtitle,
            subtitleStyle: subtitleStyle,
            infoAction: infoAction
        ))
    }
}
