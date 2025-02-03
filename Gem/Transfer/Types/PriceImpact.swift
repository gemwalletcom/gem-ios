// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import Style
import SwiftUICore

enum PriceImpactType: Equatable {
    case none
    case low(String)
    case medium(String)
    case high(String)
    case positive(String)
    
    var value: String? {
        switch self {
        case .low:
            return nil // Decided not to show low price impact.
        case .medium(let value):
            return value
        case .high(let value):
            return value
        case .positive(let value):
            return value
        case .none:
            return nil
        }
    }
    
    var color: Color {
        switch self {
        case .low, .none:
            return Colors.black
        case .medium:
            return Colors.orange
        case .high:
            return Colors.red
        case .positive:
            return Colors.green
        }
    }
}
