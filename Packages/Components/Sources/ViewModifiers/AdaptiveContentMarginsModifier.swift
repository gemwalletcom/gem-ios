// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUICore
import Style
import UIKit

struct AdaptiveContentMargins: ViewModifier {
    let maxContentWidth: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                let horizontalMargin = max((geometry.size.width - maxContentWidth) / 2, 0)
                content
                    .contentMargins(
                        .horizontal,
                        EdgeInsets(
                            top: .zero,
                            leading: horizontalMargin,
                            bottom: .zero,
                            trailing: horizontalMargin
                        ),
                        for: .scrollContent
                    )
            case .phone, .tv, .carPlay, .mac, .vision, .unspecified:
                content
            @unknown default:
                content
            }
        }
    }
}

public extension View {
    func adaptiveContentMargins(maxContentWidth: CGFloat = 720) -> some View {
        self.modifier(AdaptiveContentMargins(maxContentWidth: maxContentWidth))
    }
}
