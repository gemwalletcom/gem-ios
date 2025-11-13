// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components

@MainActor
public protocol InfoSheetActionable: Observable {
    var infoSheetModel: InfoSheetModel { get }
    var isPresentingAlertMessage: AlertMessage? { get set }
}
