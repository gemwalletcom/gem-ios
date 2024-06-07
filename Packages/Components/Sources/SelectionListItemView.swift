// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Style
import SwiftUI

public struct SelectionListItemView: View {
    
    let title: String?
    let subtitle: String?
    let value: String?
    let selection: String?
    let action: ((String) -> Void)?
    
    public init(
        title: String?,
        subtitle: String?,
        value: String?,
        selection: String?,
        action: ((String) -> Void)?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.selection = selection
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            if let value = value {
                action?(value)
            }
        }, label: {
            HStack {
                ListItemView(title: title, subtitle: subtitle)
                Spacer()
                if selection == value {
                    Image(systemName: SystemImage.checkmark)
                }
            }
        })
        .contentShape(Rectangle())
    }
}
