// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import WalletCore
import Primitives

struct WordSuggestionView: View {
    
    @Binding var word: String?
    var selectWord: StringAction = .none

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .small) {
                if let word = word {
                    if !word.isEmpty {
                        ForEach(suggest(word: word)) { word in
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
    }
    
    func suggest(word: String) -> [String] {
        let words = WalletCore.Mnemonic.suggest(prefix: word)
            .split(separator: " ")
            .map { String($0) }
        return Array(words)
    }
}
