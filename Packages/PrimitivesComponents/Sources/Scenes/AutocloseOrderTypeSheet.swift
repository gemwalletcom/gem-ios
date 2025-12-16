// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Localization

public struct AutocloseOrderTypeSheet: View {
    private let title: String
    private let options: [PerpetualOrderTypeViewModel]
    @Binding var selection: PerpetualOrderType

    public init(
        title: String,
        options: [PerpetualOrderTypeViewModel],
        selection: Binding<PerpetualOrderType>
    ) {
        self.title = title
        self.options = options
        _selection = selection
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(options) { option in
                    ListItemSelectionView(
                        title: option.title,
                        titleExtra: .none,
                        titleTag: .none,
                        titleTagType: .none,
                        subtitle: .none,
                        subtitleExtra: .none,
                        value: option.type,
                        selection: selection
                    ) {
                        selection = $0
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Localized.Perpetual.autoClose)
            .toolbar {
                ToolbarDismissItem(
                    title: .done,
                    placement: .topBarLeading
                )
            }
        }
        .presentationDetents([.height(200)])
    }
}
