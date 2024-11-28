// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct ToastModifier: ViewModifier {
    @State var isPresenting: Binding<Bool>
    let value: String
    let systemImage: String
    
    public init(
        isPresenting: Binding<Bool>,
        value: String,
        systemImage: String
    ) {
        self.isPresenting = isPresenting
        self.value = value
        self.systemImage = systemImage
    }
    
    public func body(content: Content) -> some View {
        return content
            .toast(isPresenting: isPresenting){
                AlertToast(
                    displayMode: .banner(.pop),
                    type: .systemImage(systemImage, Colors.black),
                    title: value
                )
            }
    }
}
