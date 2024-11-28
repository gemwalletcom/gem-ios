// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct SelectFilterView: View {
    private let typeModel: any FilterTypeRepresentable
    private let action: () -> Void

    init(typeModel: any FilterTypeRepresentable, action: @escaping () -> Void) {
        self.typeModel = typeModel
        self.action = action
    }

    var body: some View {
        NavigationCustomLink(
            with: ListItemView(
                title: typeModel.title,
                subtitle: typeModel.value,
                image: typeModel.image,
                imageSize: Sizing.list.image
            ),
            action: action
        )
    }
}

#Preview {
    SelectFilterView(
        typeModel: ChainsFilterTypeViewModel(type: .allChains),
        action: {}
    )
}
