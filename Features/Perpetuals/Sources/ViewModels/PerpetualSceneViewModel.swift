// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Store
import PerpetualService
import PrimitivesComponents
import Formatters

@Observable
@MainActor
public final class PerpetualSceneViewModel {
    
    private let perpetualService: PerpetualServiceable
    
    public let wallet: Wallet
    public let perpetualViewModel: PerpetualViewModel
    public let positionViewModels: [PerpetualPositionViewModel]
    
    public init(
        wallet: Wallet,
        perpetualViewModel: PerpetualViewModel,
        positionViewModels: [PerpetualPositionViewModel],
        perpetualService: PerpetualServiceable
    ) {
        self.wallet = wallet
        self.perpetualViewModel = perpetualViewModel
        self.positionViewModels = positionViewModels
        self.perpetualService = perpetualService
    }
    
    public var navigationTitle: String {
        perpetualViewModel.name
    }
}
