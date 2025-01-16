// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Style

struct NFTAttributeView: View {
    let attributes: [NFTAttribute]
    let horizontalPadding: CGFloat
    
    private let spacing = 8.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if !attributes.isEmpty {
                Text("Properties")
                    .textStyle(.subheadline)
            }
            
            VStack(alignment: .leading, spacing: spacing) {
                let rows = generateRows()
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(row, id: \.name) { attribute in
                            PropertyView(title: attribute.name, value: attribute.value)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
    }
    
    private func generateRows() -> [[NFTAttribute]] {
        var rows: [[NFTAttribute]] = []
        var currentRow: [NFTAttribute] = []
        var totalWidth: CGFloat = 0
        
        for attribute in attributes {
            let max = attribute.name.count > attribute.value.count ? attribute.name : attribute.value
            let attributeWidth = calculateAttributeWidth(for: max)
            
            if totalWidth + attributeWidth + spacing > UIScreen.main.bounds.width - horizontalPadding * 2 {
                rows.append(currentRow)
                currentRow = []
                totalWidth = 0
            }
            
            currentRow.append(attribute)
            totalWidth += attributeWidth + spacing
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private func calculateAttributeWidth(for value: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
        let size = (value as NSString).size(withAttributes: [.font: font])
        return size.width + 16
    }
    
    private struct PropertyView: View {
        let title: String
        let value: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .textStyle(.caption)
                    .lineLimit(1)
                
                Text(value)
                    .textStyle(.body)
                    .lineLimit(1)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Colors.secondaryText, lineWidth: 1)
            )
        }
    }
}



#Preview {
    NFTAttributeView(attributes: [
        .init(name: "Background", value: "Deep Space"),
        .init(name: "Body", value: "Blue"),
        .init(name: "Clothes", value: "Yellow Fuzzy Sweater"),
        .init(name: "Eyes", value: "Baby Toon"),
        .init(name: "Hats ", value: "Red Bucket Hat"),
        .init(name: "Mouth", value: "Stoked")
    ], horizontalPadding: 16)
}
