// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Combine
import Style

public struct FloatTextField: View {

    private var title: String
    @Binding private var text: String
    
    public init(
        _ title: String,
        text: Binding<String>
    ) {
        self.title = title
        self._text = text
    }
  
    public var body: some View {
        UITextField.appearance().clearButtonMode = .whileEditing
        return ZStack(alignment: .leading) {
          Text(title)
            .foregroundColor(text.isEmpty ? Colors.gray : Colors.grayLight)
            .bold(!text.isEmpty)
            .offset(y: text.isEmpty ? -8 : -28)
            .scaleEffect(text.isEmpty ? 1: 0.8, anchor: .leading)
            
            HStack {
                TextField("", text: $text)
                    .offset(y: text.isEmpty ? -8 : 0)
            }
            .padding(.vertical, 2)
        }
        .padding(.top, 16)
//        .onChange(of: text) { newValue in
//            NSLog("FloatTextField value: \(newValue)")
//        }
        //TODO: Enable animation, but avoid animating on the first appear
        //.animation(.default, value: text)
    }
}

// MARK: - Previews

struct TextInputField_Previews: PreviewProvider {
  static var previews: some View {
    Group {
        FloatTextField(
            "First Name",
            text: .constant("Satoshi N")
        )
        .previewLayout(.sizeThatFits)
        FloatTextField(
            "Last Name",
            text: .constant("Sato")
        )
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
  }
}
