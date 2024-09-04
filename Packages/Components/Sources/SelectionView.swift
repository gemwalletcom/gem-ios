// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public enum SelectionImageDirection: Identifiable {
    case left
    case right

    public var id: Self { self }
}

public struct SelectionView<T: Hashable, Content: View>: View {
    let value: T?
    let selection: T?
    let selectionDirection: SelectionImageDirection
    let content: () -> Content
    let action: ((T) -> Void)?

    public init(
        value: T?,
        selection: T?,
        selectionDirection: SelectionImageDirection = .right,
        action: ((T) -> Void)?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.value = value
        self.selection = selection
        self.selectionDirection = selectionDirection
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
                if selectionDirection == .left && selection == value {
                    selectionImageView
                }
                content()
                if selectionDirection == .right && selection == value {
                    Spacer()
                    selectionImageView
                }
            }
        })
        .contentShape(Rectangle())
    }

    private var selectionImageView: some View {
        ZStack {
            Image(systemName: SystemImage.checkmark)
        }
        .frame(width: Sizing.list.image)
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
                        selectionDirection: .right,
                        action: { selected in
                            selectedValue = selected
                        },
                        content: {
                            Text(item)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    )
                    .background(
                        selectedValue == item ? Color.blue.opacity(0.2) : Color.clear
                    )
                }
            }
            .padding()
        }
    }

    return PreviewView()
        .padding()
}
