// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct RoundButton: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric(relativeTo: .body) private var backgroundSize: CGFloat = 48
    @ScaledMetric(relativeTo: .body) private var baseFontSize: CGFloat = 16

    @State private var sceneWidth: CGFloat = 0.0

    let title: String
    let image: Image
    var action: (() -> Void)?

    public init(
        title: String,
        image: Image,
        action: (() -> Void)? = nil
    ) {
        self.action = action
        self.image = image
        self.title = title

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let sceneWidth = windowScene.screen.bounds.width
            _sceneWidth = State(initialValue: sceneWidth)
        }
    }

    public var body: some View {
        Button {
            action?()
        } label: {
            VStack(alignment: .center, spacing: Spacing.tiny) {
                ZStack {
                    Circle()
                        .fill(Colors.blue)
                        .frame(width: imageSize, height: imageSize)
                    image
                }
                Text(title)
                    .font(.system(size: titleFontSize).weight(.medium))
                    .foregroundColor(isEnabled ? Colors.secondaryText : Colors.secondaryText.opacity(0.6))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, Spacing.tiny)
        }
        .disabled(!isEnabled)
        .buttonStyle(.borderless)
        .frame(maxWidth: .infinity)
    }

    private var imageSize: CGFloat {
        min(50, backgroundSize)
    }

    private var titleFontSize: CGFloat {
        let isSmallScreen = sceneWidth <= 375
        let isAccessibilitySize = dynamicTypeSize.isAccessibilitySize

        return min(18, isSmallScreen || isAccessibilitySize ? baseFontSize * 0.71 : baseFontSize)
    }
}

struct RoundButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RoundButton(title: "Buy", image: Image(systemName: SystemImage.eyeglasses))
            RoundButton(title: "Swap", image: Image(systemName: SystemImage.share))
        }
    }
}
