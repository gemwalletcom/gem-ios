// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives
import Localization

public struct TransferExecutionView: View {
    private let model: TransferExecutionViewModel

    public init(model: TransferExecutionViewModel) {
        self.model = model
    }

    public var body: some View {
        HStack(spacing: .small) {
            primaryView
            accessoryView
        }
    }

    private var primaryView: some View {
        Button {
            model.onTap()
        } label: {
            HStack {
                ListItemView(model: model.listItemModel)
                Spacer()
            }
            .padding(.horizontal, .tiny)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var accessoryView: some View {
        HStack(spacing: .small) {
            switch model.execution.state {
            case .executing: LoadingView(size: .regular, tint: Colors.black)
            case .success: EmptyView()
            case .error: ListButton(image: Images.System.retry, action: model.onTap)
            }
            ListButton(image: Images.System.xmark, action: model.dismiss)
                .padding(.trailing, .medium)
        }
    }
}
