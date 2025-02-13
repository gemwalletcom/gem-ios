// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public extension View {
    @MainActor
    func render(for size: CGSize) -> UIImage? {
        let renderer = ImageRenderer(content: frame(width: size.width, height: size.height))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage?.withRenderingMode(.alwaysOriginal)
    }
}
