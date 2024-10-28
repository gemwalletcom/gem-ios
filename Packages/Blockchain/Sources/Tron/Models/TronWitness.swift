// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct WitnessesList: Sendable, Codable {
    let witnesses: [WitnessAccount]
}

struct WitnessAccount: Sendable, Codable {
    let address: String
    let voteCount: Int?
    let url: String
    let isJobs: Bool?
}
