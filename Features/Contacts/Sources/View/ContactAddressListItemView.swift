// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

public struct ContactAddressListItemView: View {
    let name: TextValue?
    let address: TextValue?
    let memo: TextValue?
    let description: TextValue?
    let chain: TextValue?
    let image: Image?
    
    public init(
        name: TextValue? = nil,
        address: TextValue? = nil,
        memo: TextValue? = nil,
        description: TextValue? = nil,
        chain: TextValue? = nil,
        image: Image? = nil
    ) {
        self.name = name
        self.address = address
        self.memo = memo
        self.description = description
        self.chain = chain
        self.image = image
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: .medium) {
            if let image = image {
                image
                    .resizable()
                    .frame(width: 28, height: 28)
                    .aspectRatio(contentMode: .fit)
            }
            VStack(alignment: .leading, spacing: .tiny) {
                if let name, !name.text.isEmpty {
                    Text(name.text)
                        .textStyle(name.style)
                }
                
                if let description, !description.text.isEmpty {
                    Text(description.text)
                        .textStyle(description.style)
                }
                
                if let address, !address.text.isEmpty {
                    Text(address.text)
                        .textStyle(address.style)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                if let memo, !memo.text.isEmpty {
                    Text(memo.text)
                        .textStyle(memo.style)
                }
                
                if let chain, !chain.text.isEmpty {
                    Text(chain.text)
                        .textStyle(chain.style)
                }
            }
        }
        .padding(.trailing, .small)
    }
}
