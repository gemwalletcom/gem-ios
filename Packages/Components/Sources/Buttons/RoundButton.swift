// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct RoundButton: View {
    @Environment(\.isEnabled) private var isEnabled
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
    }
    
    public var body: some View {
        Button {
            action?()
        } label: {
            VStack(alignment: .center) {
                image
                    .frame(width: 48, height: 48)
                    .background(Colors.blue)
                    .cornerRadius(24)
                    .opacity(isEnabled ? 1 : 0.6)
                Text(title)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(Colors.secondaryText)
                    .font(.system(size: 16).weight(.medium))
                    .lineLimit(1)
                    .padding(.horizontal, 4)
            }
        }
        .disabled(!isEnabled)
        .buttonStyle(.borderless)
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
