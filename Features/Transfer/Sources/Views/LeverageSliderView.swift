// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct LeverageSliderView: View {

    let maxLeverage: UInt8

    @Binding var selectedLeverage: UInt8

    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)

    private var sliderValue: Binding<Double> {
        Binding(
            get: { Double(selectedLeverage) },
            set: { newValue in
                if UInt8(newValue) != selectedLeverage {
                    impactGenerator.impactOccurred()
                    selectedLeverage = UInt8(newValue)
                }
            }
        )
    }

    var body: some View {
        VStack(alignment: .center, spacing: Spacing.small) {
            Text("\(selectedLeverage)x")
                .textStyle(.boldTitle)
                .foregroundStyle(Colors.blue)
            HStack(spacing: Spacing.small) {
                Text("1x")
                    .textStyle(.caption)
                    .foregroundStyle(Colors.gray)

                Slider(value: sliderValue, in: 1...Double(maxLeverage), step: 1)
                    .tint(Colors.blue)

                Text("\(maxLeverage)x")
                    .textStyle(.caption)
                    .foregroundStyle(Colors.gray)
            }
        }
        .padding(.vertical, Spacing.small)
    }
}
