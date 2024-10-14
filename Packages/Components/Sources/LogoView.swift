// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct LogoView: View {

    public init() {}

    public var body: some View {
        ZStack {
            Image(.gemLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
