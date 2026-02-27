// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct SelectionView<T: Hashable, Content: View>: View {
    let value: T?
    let selection: T?
    let content: () -> Content
    let action: ((T) -> Void)?

    public init(
        value: T?,
        selection: T?,
        action: ((T) -> Void)?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.value = value
        self.selection = selection
        self.content = content
        self.action = action
    }

    public var body: some View {
        Button(action: {
            if let value = value {
                action?(value)
            }
        }, label: {
            HStack {
                content()
                if selection == value {
                    Spacer()
                    SelectionImageView()
                }
            }
        })
        .contentShape(Rectangle())
    }
}

// MARK: - Previews

#Preview {
    struct PreviewView: View {
        @State private var selectedValue: String? = "Banana"
        private let items = ["Apple", "Banana", "Orange"]

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Select a Fruit")
                    .font(.headline)

                ForEach(items, id: \.self) { item in
                    SelectionView(
                        value: item,
                        selection: selectedValue,
                        action: { selected in
                            selectedValue = selected
                        },
                        content: {
                            Text(item)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(.extraLight))
                                .cornerRadius(8)
                        }
                    )
                    .background(
                        selectedValue == item ? Color.blue.opacity(.opacity20) : Color.clear
                    )
                }
            }
            .padding()
        }
    }

    return PreviewView()
        .padding()
}
