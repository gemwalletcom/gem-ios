// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct AsyncImageView: View {
    
    let url: URL?
    let size: CGFloat
    let placeholder: Placeholder

    public enum Placeholder {
        case letter(Character)
    }
    
    public init(
        url: URL?,
        size: CGFloat = 40,
        placeholder: Placeholder = Placeholder.letter(" ")
    ) {
        self.url = url
        self.size = size
        self.placeholder = placeholder
    }

    public var body: some View {
        CachedAsyncImage(url: url, scale: UIScreen.main.scale) {
            $0.resizable()
        } placeholder: {
            switch placeholder {
            case .letter(let character):
                Text(String(character).capitalized)
                    .fontWeight(.semibold)
                    .frame(width: size, height: size)
                    .foregroundStyle(Colors.white)
                    .background(Colors.grayLight)
            }
        }
        .frame(width: size, height: size)
        .cornerRadius(size/2)
    }
}
