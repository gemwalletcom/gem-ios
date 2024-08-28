// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

protocol ChipSelectable: Hashable {
    var title: String { get }
    static var primary: Self { get }
}

struct MenuChipView<T: ChipSelectable>: View {
    let options: [T]
    @Binding var selectedOption: T

    var body: some View {
        Menu {
            ForEach(options, id: \.title) { option in
                Button(action: {
                    selectedOption = option
                }, label: {
                    Text(option.title)
                    Spacer()
                    if selectedOption == option {
                        Image(systemName: SystemImage.checkmark)
                    }
                })
            }
        } label: {
            HStack(spacing: Spacing.extraSmall) {
                Text(selectedOption.title)
                Image(systemName: SystemImage.chevronDown)
            }
            .font(.body)
            .foregroundStyle(selectedOption == T.primary ? .black : .white)
            .padding(.horizontal, Spacing.extraSmall + Spacing.small)
            .padding(.vertical, Spacing.extraSmall)
            .background(
                Capsule()
                    .fill(selectedOption == T.primary ? .white : Colors.blue)
                    .if(selectedOption == T.primary) {
                        $0.stroke(Color.gray.opacity(0.33), lineWidth: 0.66)
                    }
            )
        }
    }
}

#Preview {
    @State var chainsOptions = [CainsFilterType.allChains, CainsFilterType.chains(selected: [])]
    @State var selectedOption: CainsFilterType = .allChains

    return MenuChipView(options: chainsOptions, selectedOption: $selectedOption)
}


