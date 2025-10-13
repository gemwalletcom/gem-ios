// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Style
import SwiftUI

public extension SwapProvider {
    var image: Image {
        switch self {
        case .uniswapV3, .uniswapV4: Images.SwapProviders.uniswap
        case .jupiter: Images.SwapProviders.jupiter
        case .pancakeswapV3, .pancakeswapAptosV2: Images.SwapProviders.pancakeswap
        case .thorchain: Images.SwapProviders.thorchain
        case .across: Images.SwapProviders.across
        case .oku: Images.SwapProviders.oku
        case .wagmi: Images.SwapProviders.wagmi
        case .cetus, .cetusAggregator: Images.SwapProviders.cetus
        case .stonfiV2: Images.SwapProviders.stonfi
        case .mayan: Images.SwapProviders.mayan
        case .reservoir: Images.SwapProviders.reservoir
        case .symbiosis: Images.SwapProviders.symbiosis
        case .chainflip: Images.SwapProviders.chainflip
        case .relay: Images.SwapProviders.relay
        case .aerodrome: Images.SwapProviders.aerodrome
        case .hyperliquid: Images.SwapProviders.hyperliquid
        case .nearIntents: Images.Chains.near
        }
    }
}
