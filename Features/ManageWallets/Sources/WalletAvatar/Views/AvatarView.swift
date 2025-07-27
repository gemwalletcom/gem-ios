// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import PrimitivesComponents
import Primitives

public struct AvatarView: View {
    
    let avatarImage: AssetImage
    let size: CGFloat
    let action: VoidAction
    
    public init(
        avatarImage: AssetImage,
        size: CGFloat,
        action: VoidAction
    ) {
        self.avatarImage = avatarImage
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button {
            action?()
        } label: {
            AssetImageView(
                assetImage: avatarImage,
                size: size
            )
        }
    }
}
