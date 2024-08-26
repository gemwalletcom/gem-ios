// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style
import Primitives

struct ContextMenuCopy: View {
    
    let title: String
    let value: String
    
    var body: some View {
        Button(action: {
            UIPasteboard.general.string = value
        }) {
            Text(title)
            Image(systemName: SystemImage.copy)
        }
    }
}

struct ContextMenuViewURL: View {
    
    let title: String
    let url: URL
    let image: String
    
    var body: some View {
        Button(action: {
            UIApplication.shared.open(url)
        }) {
            Text(title)
            Image(systemName: image)
        }
    }
}

struct ContextMenuDelete: View {

    let action: VoidAction
    
    var body: some View {
        Button(role: .destructive) { action?() } label: {
            Label(Localized.Common.delete, systemImage: SystemImage.delete)
        }
    }
}

struct ContextMenuPin: View {

    let isPinned: Bool
    let action: VoidAction

    var body: some View {
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

struct ContextMenuItem: View {
    
    let title: String
    let image: String
    let action: VoidAction
    
    var body: some View {
        Button(role: .none) { action?() } label: {
            Label(title, systemImage: image)
        }
        .tint(Colors.gray)
    }
}
