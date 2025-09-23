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

extension Gemstone.PerpetualDirection {
    var asPrimitive: Primitives.PerpetualDirection {
        switch self {
        case .short: .short
        case .long: .long
        }
    }
}
