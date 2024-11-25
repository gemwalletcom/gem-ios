// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

struct SelectChainView: View {
    private let typeModel: ChainsFilterTypeViewModel
    private let action: () -> Void

    init(typeModel: ChainsFilterTypeViewModel, action: @escaping () -> Void) {
        self.typeModel = typeModel
        self.action = action
    }

    var body: some View {
        NavigationCustomLink(
            with: ListItemView(
                title: typeModel.title,
                subtitle: typeModel.value,
                image: typeModel.chainsImage
            ),
            action: action
        )
    }
}

#Preview {
    SelectChainView(typeModel: .init(type: .allChains), action: {})
}
