// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct RoundButton: View {
    let title: String
    let image: Image
    let isEnabled: Bool
    var action: (() -> Void)?

    public init(
        title: String,
        image: Image,
        isEnabled: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.action = action
        self.image = image
        self.isEnabled = isEnabled
        self.title = title
    }
    
    public var body: some View {
        Button {
            action?()
        } label: {
            VStack(alignment: .center) {
                image
                    .foregroundStyle(Colors.whiteSolid)
                    .frame(width: 48, height: 48)
                    .background(Colors.blue)
                    .cornerRadius(24)
                    .opacity(isEnabled ? 1 : 0.5)
                    .liquidGlass()
                Text(title)
                    .allowsTightening(true)
                    .truncationMode(.tail)
                    .foregroundStyle(Colors.secondaryText)
                    .font(.system(size: 16).weight(.medium))
                    .lineLimit(1)
            }
        }
        .disabled(!isEnabled)
        .buttonStyle(.borderless)
    }
}

struct RoundButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RoundButton(title: "Buy", image: Images.System.eyeglasses)
            RoundButton(title: "Swap", image: Images.System.share)
        }
    }
}
