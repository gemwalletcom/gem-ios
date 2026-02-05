// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct SetPriceAlertViewModelState {
    var type: SetPriceAlertType = .price

    var amount: String {
        get {
            switch type {
            case .price: priceAmount
            case .percentage: percentageAmount
            }
        }
        set {
            switch type {
            case .price: priceAmount = newValue
            case .percentage: percentageAmount = newValue
            }
        }
    }

    var alertDirection: PriceAlertDirection? {
        get {
            switch type {
            case .price: priceDirection
            case .percentage: percentageDirection
            }
        }
        set {
            switch type {
            case .price: priceDirection = newValue
            case .percentage: percentageDirection = newValue ?? .up
            }
        }
    }

    private var priceAmount: String = .empty
    private var percentageAmount: String = .empty

    private var priceDirection: PriceAlertDirection?
    private var percentageDirection: PriceAlertDirection = .up

    init(price: Double? = nil) {
        if let price {
            self.type = .price
            self.priceAmount = String(price)
        }
    }
}
