// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives

public protocol EmptyContentViewable {
    var type: EmptyContentType { get }
    var title: String { get }
    var description: String? { get }
    var image: Image? { get }
    var buttons: [EmptyAction] { get }
}
