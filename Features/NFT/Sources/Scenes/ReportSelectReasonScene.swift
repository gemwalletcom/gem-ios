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
                    NavigationCustomLink(
                        with: ListItemView(title: reasonViewModel.title),
                        action: { model.submitReport(reason: reasonViewModel.reason.rawValue) }
                    )
                }
            }
        }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
