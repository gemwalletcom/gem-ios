// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct NftImageView: View {
    
    let assetImage: AssetImage
    
    public init(assetImage: AssetImage) {
        self.assetImage = assetImage
    }
    
    public var body: some View {
        CachedAsyncImage(url: assetImage.imageURL) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Rectangle()
                        .foregroundStyle(Colors.grayLight)
                    LoadingView()
                }
            case .success(let image):
                image.resizable()
            case .failure:
                //Add custom preview
                Rectangle()
                    .foregroundStyle(Colors.grayLight)
            @unknown default:
                Rectangle()
                    .foregroundStyle(Colors.grayLight)
            }
        }
    }
}
