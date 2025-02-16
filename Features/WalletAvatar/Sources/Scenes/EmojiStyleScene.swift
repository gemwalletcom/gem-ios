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
    
    @State private var model: EmojiStyleViewModel

    public init(model: EmojiStyleViewModel) {
        _model = State(initialValue: model)
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                emojiView(color: model.color, emoji: model.text)

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
                        model.onDoneEmojiValue()
                        dismiss()
                    }
                    .bold()
                    .disabled(model.text.isEmpty)
                }
            }
        }
    }
    
    private func emojiView(color: Color, emoji: String) -> some View {
        EmojiView(color: color, emoji: emoji)
            .frame(width: emojiViewSize, height: emojiViewSize)
    }
    
    private var picker: some View {
        Picker("", selection: $selectedTab.animation()) {
            Text(Localized.Common.emoji).tag(Tab.emoji)
            Text(Localized.Common.style).tag(Tab.style)
        }
        .pickerStyle(SegmentedPickerStyle())
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
                                    .foregroundColor(Colors.white)
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
            switch selectedTab {
            case .emoji:
                model.setRandomEmoji()
            case .style:
                model.colorList = EmojiStyleViewModel.shuffleColorList()
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
        .buttonStyle(.blue())
    }
}
