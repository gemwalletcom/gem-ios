// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

public protocol FilterTypeRepresentable {
    var value: String { get }
    var title: String { get }
    var image: AssetImage { get }
}
