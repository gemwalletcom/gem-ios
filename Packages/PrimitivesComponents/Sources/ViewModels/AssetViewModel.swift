import Foundation
import Primitives
import Components

public struct AssetViewModel {
    public let asset: Asset

    public init(asset: Asset) {
        self.asset = asset
    }

    public var title: String {
        String(format: "%@ (%@)", asset.name, asset.symbol)
    }

    public var name: String {
        asset.name
    }

    public var symbol: String {
        asset.symbol
    }

    public var supportMemo: Bool {
        asset.chain.isMemoSupported
    }

    public var assetImage: AssetImage {
        AssetIdViewModel(assetId: asset.id).assetImage
    }
}
