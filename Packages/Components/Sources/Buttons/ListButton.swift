// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct ListButton: View {
    
    var action: (() -> Void)?
    let title: String?
    let image: Image
    let padding: CGFloat

    public init(
        title: String? = .none,
        image: Image,
        padding: CGFloat = 0,
        action:  (() -> Void)? = nil
    ) {
        self.action = action
        self.image = image
        self.title = title
        self.padding = padding
    }
    
    public var body: some View {
        Button {
            action?()
        } label: {
            HStack(alignment: .center) {
                image
                    .frame(width: 24, height: 24)
                if let title = title {
                    Text(title)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.all, padding)
        }
        .buttonStyle(.borderless)
        .tint(Colors.black)
    }
}
struct ListButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ListButton(title: "Paste", image: Image(systemName: SystemImage.paste))
            ListButton(title: "Scan", image: Image(systemName: SystemImage.qrCode))
        }
    }
}
