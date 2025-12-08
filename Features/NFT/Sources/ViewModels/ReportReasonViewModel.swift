// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

struct ReportReasonViewModel: Identifiable, Hashable {
    let reason: ReportReason

    var id: String { reason.id }

    var title: String {
        switch reason {
        case .spam: Localized.Nft.Report.Reason.spam
        case .malicious: Localized.Nft.Report.Reason.malicious
        case .inappropriate: Localized.Nft.Report.Reason.inappropriate
        case .copyright: Localized.Nft.Report.Reason.copyright
        case .other: Localized.Transfer.Other.title
        }
    }

    static var allCases: [ReportReasonViewModel] {
        ReportReason.allCases.map { ReportReasonViewModel(reason: $0) }
    }
}
