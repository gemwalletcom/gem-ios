// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public extension View {
    /// Renders the SwiftUI `View` into a `UIImage` with the specified size and color scheme.
    ///
    /// - Parameters:
    ///   - size: The target size for the rendered image.
    ///   - colorScheme: The color scheme (`.light` or `.dark`) to be applied during rendering. If `nil`, the system's current color scheme is used.
    /// - Returns: A `UIImage` representing the rendered view, or `nil` if rendering fails.
    ///
    /// - Note: The width and height are reduced by `-1` to prevent rendering artifacts, particularly unwanted borders around circular views.
    @MainActor
    func render(for size: CGSize, colorScheme: ColorScheme? = nil) -> UIImage? {
        let renderer = ImageRenderer(content: self
            .frame(width: size.width - 1, height: size.height - 1)
            .environment(\.colorScheme, colorScheme ?? (UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light))
        )
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage?.withRenderingMode(.alwaysOriginal)
    }
}
