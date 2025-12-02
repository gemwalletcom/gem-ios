// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Localization

struct ReportSelectReasonScene: View {
    private let model: ReportNftViewModel

    init(model: ReportNftViewModel) {
        self.model = model
    }

    var body: some View {
        List {
            Section {
                ForEach(model.reasons) { reasonViewModel in
                    switch reasonViewModel.type {
                    case .preselected:
                        NavigationCustomLink(
                            with: ListItemView(title: reasonViewModel.title),
                            action: { model.submitReport(reason: reasonViewModel.reason.rawValue) }
                        )
                    case .manual:
                        NavigationLink(value: reasonViewModel) {
                            ListItemView(title: reasonViewModel.title)
                        }
                    }
                }
            } header: {
                Text(Localized.Nft.Report.selectReportHeader)
            }
        }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
