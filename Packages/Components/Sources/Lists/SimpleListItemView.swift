// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public protocol SimpleListItemViewable {
    var title: String { get }
    var titleStyle: TextStyle { get }
    var assetImage: AssetImage { get }

    var subtitle: String? { get }
    var subtitleExtra: String? { get }
    var subtitleStyle: TextStyle { get }
    var subtitleStyleExtra: TextStyle { get }

    var imageSize: CGFloat { get }
    var cornerRadius: CGFloat { get }
}

public extension SimpleListItemViewable {
    var titleStyle: TextStyle { .body }
    var imageSize: CGFloat { .image.medium }
    var cornerRadius: CGFloat { imageSize / 2 }
    var subtitle: String? { .none }
    var subtitleExtra: String? { .none }
    var subtitleStyle: TextStyle { .calloutSecondary }
    var subtitleStyleExtra: TextStyle { .calloutSecondary }
}

public struct SimpleListItemView: View {
    private let model: any SimpleListItemViewable

    public init(model: any SimpleListItemViewable) {
        self.model = model
    }

    public var body: some View {
        ListItemView(
            title: model.title,
            titleStyle: model.titleStyle,
            subtitle: model.subtitle,
            subtitleStyle: model.subtitleStyle,
            subtitleExtra: model.subtitleExtra,
            subtitleStyleExtra: model.subtitleStyleExtra,
            imageStyle: AssetImageStyle(
                assetImage: model.assetImage,
                imageSize: model.imageSize,
                overlayImageSize: .image.overlayImage.chain,
                cornerRadiusType: .custom(model.cornerRadius)
            )
        )
    }
}
