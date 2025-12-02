// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Localization

struct ReportUserReasonScene: View {
    @State private var model: ReportNftViewModel

    init(model: ReportNftViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        Form {
            Section {
                TextField(Localized.Nft.Report.placeholder, text: $model.reason, axis: .vertical)
                    .lineLimit(4...8)
            } header: {
                VStack {
                    Text(Emoji.policeOfficer)
                        .font(.system(size: Sizing.image.semiLarge))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .safeAreaView {
            StateButton(
                text: Localized.Transfer.confirm,
                type: .primary(model.submitButtonState),
                action: model.submitUserReport
            )
            .frame(maxWidth: .scene.button.maxWidth)
            .padding(.bottom, .scene.bottom)
        }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
