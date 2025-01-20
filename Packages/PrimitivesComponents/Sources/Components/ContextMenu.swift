// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style
import Primitives
import Localization

public struct ContextMenuCopy: View {
    private let title: String
    private let value: String

    public init(
        title: String = Localized.Common.copy,
        value: String
    ) {
        self.title = title
        self.value = value
    }

    public var body: some View {
        Button(action: {
            UIPasteboard.general.string = value
        }) {
            Text(Localized.Common.copy)
            Images.System.copy
        }
    }
}

public struct ContextMenuDelete: View {
    private let action: VoidAction

    public init(action: VoidAction) {
        self.action = action
    }

    public var body: some View {
        Button(role: .destructive) { action?() } label: {
            Label(Localized.Common.delete, systemImage: SystemImage.delete)
        }
    }
}

public struct ContextMenuPin: View {
    private let isPinned: Bool
    private let action: VoidAction

    public init(isPinned: Bool, action: VoidAction) {
        self.isPinned = isPinned
        self.action = action
    }

    public var body: some View {
        Button { action?() } label: {
            Label(label, systemImage: image)
        }
    }

    private var label: String {
        isPinned ? Localized.Common.unpin : Localized.Common.pin
    }

    private var image: String {
        isPinned ? SystemImage.unpin : SystemImage.pin
    }
}

public struct ContextMenuItem: View {
    private let title: String
    private let image: String
    private let action: VoidAction

    public init(title: String, image: String, action: VoidAction) {
        self.title = title
        self.image = image
        self.action = action
    }

    public var body: some View {
        Button(role: .none) { action?() } label: {
            Label(title, systemImage: image)
        }
        .tint(Colors.gray)
    }
}
