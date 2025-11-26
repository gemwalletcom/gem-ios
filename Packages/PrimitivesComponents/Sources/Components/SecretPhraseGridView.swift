// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct SecretPhraseGridView: View {
    private let rows: [[WordIndex]]
    private let highlightIndex: Int?

    public init(
        rows: [[WordIndex]],
        highlightIndex: Int? = .none
    ) {
        self.rows = rows
        self.highlightIndex = highlightIndex
    }
    
    public var body: some View {
        Grid(alignment: .leading) {
            ForEach(rows, id: \.self) { words in
                GridRow {
                    ForEach(words) { word in
                        HStack {
                            Text("\(word.index + 1).")
                                .fontWeight(.semibold)
                                .foregroundColor(Colors.grayLight)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, .small)
                            Text(word.word)
                                .fontWeight(.semibold)
                                .foregroundColor(Colors.black)
                                .allowsTightening(false)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.small)
                        .background(Colors.listStyleColor)
                        .cornerRadius(10)
                        .overlay {
                            if highlightIndex == word.index {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Colors.blue, lineWidth: 2)
                            }
                        }
                    }
                }.padding(2)
            }
        }
        .padding(.horizontal, .medium)
        .frame(maxWidth: .scene.content.maxWidth)
    }
}
