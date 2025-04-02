// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style

import struct Gemstone.SwapProviderType

public extension Gemstone.SwapProviderType {
    var image: Image {
        switch id {
        case .uniswapV3, .uniswapV4: Images.SwapProviders.uniswap
        case .jupiter: Images.SwapProviders.jupiter
        case .orca: Images.SwapProviders.orca
        case .pancakeSwapV3, .pancakeSwapAptosV2: Images.SwapProviders.pancakeswap
        case .thorchain: Images.SwapProviders.thorchain
        case .across: Images.SwapProviders.across
        case .okuTrade: Images.SwapProviders.oku
        case .wagmi: Images.SwapProviders.wagmi
        case .cetus: Images.SwapProviders.cetus
        case .stonFiV2: Images.SwapProviders.stonfi
        case .mayan: Images.SwapProviders.mayan
        }
    }
}
