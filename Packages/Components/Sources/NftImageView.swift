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
                errorView
            @unknown default:
                errorView
            }
        }
    }
    
    private var errorView: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Colors.grayLight)
            if let type = assetImage.type {
                Text(type)
                    .font(.title)
                    .lineLimit(1)
                    .foregroundStyle(Colors.black.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
    }
}
