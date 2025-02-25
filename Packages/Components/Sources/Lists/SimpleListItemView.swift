// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public protocol SimpleListItemViewable {
    var title: String { get }
    var subtitle: String? { get }
    var image: Image { get }

    var imageSize: CGFloat { get }
    var cornerRadius: CGFloat { get }
}

public extension SimpleListItemViewable {
    var imageSize: CGFloat { .image.medium }
    var cornerRadius: CGFloat { imageSize / 2 }
    var subtitle: String? { .none }
}

public struct SimpleListItemView: View {
    private let model: any SimpleListItemViewable

    public init(model: any SimpleListItemViewable) {
        self.model = model
    }

    public var body: some View {
        ListItemView(
            title: model.title,
            subtitle: model.subtitle,
            image: model.image,
            imageSize: model.imageSize,
            cornerRadius: model.cornerRadius
        )
    }
}
