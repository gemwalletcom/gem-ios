// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct GridPosterView: View {
    
    private let assetImage: AssetImage
    private let title: String?
    
    public init(
        assetImage: AssetImage,
        title: String?
    ) {
        self.assetImage = assetImage
        self.title = title
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            NftImageView(assetImage: assetImage)
                .cornerRadius(.medium)
                .aspectRatio(1, contentMode: .fit)
            
            if let title {            
                Text(title)
                    .font(.body)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
    }
}

#Preview {
    GridPosterView(
        assetImage: AssetImage(
            imageURL: URL(string: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png"),
            placeholder: nil,
            chainPlaceholder: nil
        ),
        title: "gemcoder.eth"
    )
    .frame(width: 300, height: 300)
}
