// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

struct ReportReasonViewModel: Identifiable, Hashable {
    enum ReasonType {
        case preselected
        case manual
    }

    let reason: ReportReason

    var id: String { reason.id }

    var title: String {
        switch reason {
        case .spam: Localized.Nft.Report.Reason.spam
        case .scam: Localized.Nft.Report.Reason.scam
        case .inappropriate: Localized.Nft.Report.Reason.inappropriate
        case .copyright: Localized.Nft.Report.Reason.copyright
        case .other: Localized.Transfer.Other.title
        }
    }

    var type: ReasonType {
        switch reason {
        case .spam, .scam, .inappropriate, .copyright: .preselected
        case .other: .manual
        }
    }

    static var allCases: [ReportReasonViewModel] {
        ReportReason.allCases.map { ReportReasonViewModel(reason: $0) }
    }
}
