// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization

public typealias InfoSheetAction = @MainActor @Sendable () -> Void

public enum InfoSheetButton: Sendable {
    case url(URL)
    case action(title: String, action: InfoSheetAction)
}

public enum InfoSheetImage: Sendable {
    case image(Image)
    case assetImage(AssetImage)
}

public struct InfoSheetModel: Sendable {
    public let title: String
    public let description: String
    public let image: InfoSheetImage?
    public let button: InfoSheetButton?
    public let titleStyle: TextStyle
    public let descriptionStyle: TextStyle
    
    public var buttonTitle: String {
        switch button {
        case .url, .none: Localized.Common.learnMore
        case .action(let title, _): title
        }
    }
    
    public init(
        title: String, 
        description: String, 
        image: InfoSheetImage? = nil,
        button: InfoSheetButton? = nil,
        titleStyle: TextStyle = .boldTitle,
        descriptionStyle: TextStyle = .bodySecondary
    ) {
        self.title = title
        self.description = description
        self.image = image
        self.button = button
        self.titleStyle = titleStyle
        self.descriptionStyle = descriptionStyle
    }
    
    var shouldShowButton: Bool { button != nil }
}
