// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct AmountView: View {
    
    public let title: String
    public let subtitle: String?
    
    public init(title: String, subtitle: String?) {
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(title)
                .foregroundColor(Colors.black)
                .font(.system(size: 52))
                .scaledToFit()
                .fontWeight(.semibold)
                .minimumScaleFactor(0.4)
                .truncationMode(.middle)
                .lineLimit(1)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Colors.gray)
            }
        }
    }
}
