// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

struct LogoView: View {
    var body: some View {
        ZStack {
            Image(.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 128)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
