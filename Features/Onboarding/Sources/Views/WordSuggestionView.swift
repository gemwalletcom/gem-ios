// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import WalletCore
import Primitives

struct WordSuggestionView: View {
    
    let words: [String]
    var selectWord: StringAction = .none

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .small) {
                ForEach(words) { word in
                    Button(word) {
                        selectWord?(word)
                    }
                    .buttonStyle(.blue(paddingHorizontal: 10, paddingVertical: 6))
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
    }
}
