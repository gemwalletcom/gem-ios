import Style
import Components
import Primitives

public struct SymbolViewModel: Sendable, AmountDisplayable {
    public let asset: Asset

    public init(asset: Asset) {
        self.asset = asset
    }

    public var amount: TextValue {
        TextValue(
            text: asset.symbol,
            style: TextStyle(
                font: .body,
                color: Colors.black,
                fontWeight: .semibold
            ),
            lineLimit: 1
        )
    }

    public var fiat: TextValue? { nil }

    public var assetImage: AssetImage? {
        AssetViewModel(asset: asset).assetImage
    }
}
