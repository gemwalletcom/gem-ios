// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Localization

public struct EmojiStyleScene: View {
    private enum Tab: Equatable {
        case emoji, style
    }

    @Environment(\.dismiss) private var dismiss
    
    private let emojiViewSize = Sizing.image.extraLarge
    @State private var selectedTab: Tab = .emoji
    @Binding private var image: UIImage?
    
    @State private var model = EmojiViewModel()

    public init(image: Binding<UIImage?>) {
        _image = image
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                emojiView
                    .frame(width: emojiViewSize, height: emojiViewSize)
                
                changeBackgroundButton

                picker
                    .padding(.horizontal, Spacing.medium)
                    .padding(.top, Spacing.medium)

                Group {
                    switch selectedTab {
                    case .emoji:
                        emojiListView
                    case .style:
                        colorsView
                    }
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.medium)
                
                magicButton
                    .padding(.horizontal, Spacing.medium)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        dismiss()
                    }.bold()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Localized.Common.done) {
                        image = emojiView.render(for: CGSize(width: emojiViewSize, height: emojiViewSize))
                        dismiss()
                    }
                    .bold()
                    .disabled(model.text.isEmpty)
                }
            }
        }
    }
    
    private var picker: some View {
        Picker("", selection: $selectedTab.animation()) {
            Text(Localized.Common.emoji).tag(Tab.emoji)
            Text(Localized.Common.style).tag(Tab.style)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var emojiView: some View {
        EmojiView(color: model.color, emoji: model.text)
    }
    
    private var changeBackgroundButton: some View {
        Button(action: {
            model.color = .random()
        }) {
            Text(Localized.Avatar.changeBackground + Emoji.WalletAvatar.magic.rawValue)
                .textCase(nil)
        }
        .buttonStyle(.clear)
    }
    
    private var emojiListView: some View {
        ScrollView {
            LazyVGrid(
                columns: model.emojiColumns,
                alignment: .center,
                spacing: Spacing.medium
            ) {
                ForEach(model.emojiList, id: \.self) { item in
                    Button(action: {
                        withAnimation {
                            model.text = item.emoji
                        }
                    }) {
                        Circle()
                            .fill(item.color)
                            .overlay {
                                Text(item.emoji)
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .minimumScaleFactor(0.5)
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
                }
                
            }
        }
    }
    
    private var colorsView: some View {
        ScrollView {
            LazyVGrid(
                columns: model.colorColumns,
                alignment: .center,
                spacing: Spacing.medium
            ) {
                ForEach(model.colorList, id: \.self) { color in
                    Button(action: {
                        withAnimation {
                            model.color = color
                        }
                    }) {
                        Circle()
                            .fill(color)
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
                }
                
            }
        }
    }
    
    private var magicButton: some View {
        Button(action: {
            withAnimation {
                switch selectedTab {
                case .emoji:
                    model.emojiList = EmojiViewModel.shuffleList()
                case .style:
                    model.colorList = EmojiViewModel.shuffleColorList()
                }
            }
        }) {
            Text(
                [
                    Emoji.WalletAvatar.magic.rawValue,
                    Localized.Common.magicButton,
                    Emoji.WalletAvatar.magic.rawValue
                ].joined(separator: " ")
            )
        }
        .buttonStyle(.listStyleColor())
    }
}

#Preview {
    EmojiStyleScene(image: .constant(nil))
}
