// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct SecretPhraseGridView: View {
    
    let rows: [[WordIndex]]
    let highlightIndex: Int?

    init(
        rows: [[WordIndex]],
        highlightIndex: Int? = .none
    ) {
        self.rows = rows
        self.highlightIndex = highlightIndex
    }
    
    var body: some View {
        Grid(alignment: .leading) {
            ForEach(rows, id: \.self) { words in
                GridRow {
                    ForEach(words) { word in
                        HStack {
                            Text("\(word.index + 1).")
                                .fontWeight(.semibold)
                                .foregroundColor(Colors.grayLight)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, Spacing.small)
                            Text(word.word)
                                .fontWeight(.semibold)
                                .foregroundColor(Colors.black)
                                .allowsTightening(false)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(Spacing.small)
                        .frame(maxWidth: (Spacing.scene.content.maxWidth / 2) - (Spacing.small * 2))
                        .background(Colors.grayVeryLight)
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
    }
}

//struct SecretPhraseGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        SecretPhraseGridView()
//    }
//}
