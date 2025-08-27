import Foundation
import Gemstone
import Primitives

extension GemPerpetualConfirmData {
    func map() throws -> PerpetualConfirmData {
        PerpetualConfirmData(
            direction: direction.asPrimitive,
            asset: try asset.map(),
            assetIndex: assetIndex,
            price: price,
            fiatValue: fiatValue,
            size: size
        )
    }
}

extension GemPerpetualDirection {
    var asPrimitive: PerpetualDirection {
        switch self {
        case .short: .short
        case .long: .long
        }
    }
}
