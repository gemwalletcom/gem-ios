// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization

public enum InfoSheetImage: Sendable {
    case image(Image)
    case assetImage(AssetImage)
}

public typealias InfoSheetAction = @MainActor @Sendable () -> Void

public enum InfoSheetButton: Sendable {
    case url(URL)
    case action(title: String, action: InfoSheetAction)
}

public protocol InfoSheetModelViewable: Sendable {
    var title: String { get }
    var description: String { get }
    var buttonTitle: String { get }

    var button: InfoSheetButton? { get }
    var image: InfoSheetImage? { get }
}
