// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public protocol WheelPickerDisplayable: Hashable, Identifiable {
    var displayText: String { get }
}

public struct WheelPickerView<T: WheelPickerDisplayable>: View {
    let options: [T]
    @Binding var selection: T

    public init(options: [T], selection: Binding<T>) {
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        VStack(spacing: .zero) {
            Picker("", selection: $selection) {
                ForEach(options) { option in
                    Text(option.displayText)
                        .tag(option)
                }
            }
            .pickerStyle(.wheel)
            .padding()
        }
    }
}
