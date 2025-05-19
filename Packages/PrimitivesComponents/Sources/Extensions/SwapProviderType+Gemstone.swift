// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Style
import SwiftUI

import struct Gemstone.SwapProviderType

public extension Gemstone.SwapProviderType {
    var image: Image {
        switch id {
        case .uniswapV3, .uniswapV4: Images.SwapProviders.uniswap
        case .jupiter: Images.SwapProviders.jupiter
        case .orca: Images.SwapProviders.orca
        case .pancakeswapV3, .pancakeswapAptosV2: Images.SwapProviders.pancakeswap
        case .thorchain: Images.SwapProviders.thorchain
        case .across: Images.SwapProviders.across
        case .oku: Images.SwapProviders.oku
        case .wagmi: Images.SwapProviders.wagmi
        case .cetus: Images.SwapProviders.cetus
        case .stonfiV2: Images.SwapProviders.stonfi
        case .mayan: Images.SwapProviders.mayan
        case .reservoir: Images.SwapProviders.reservoir
        case .symbiosis: Images.SwapProviders.symbiosis
        case .chainflip: Images.SwapProviders.chainflip
        }
    }
}
