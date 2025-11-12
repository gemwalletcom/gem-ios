// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct LeveragePickerView: View {
    let leverageOptions: [UInt8]

    @Binding var selectedLeverage: UInt8

    var body: some View {
        VStack(spacing: .zero) {
            Picker("", selection: $selectedLeverage) {
                ForEach(leverageOptions, id: \.self) {
                    Text("\($0)x").tag($0)
                }
            }
            .pickerStyle(.wheel)
            .padding()
        }
    }
}
