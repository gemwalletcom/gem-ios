// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Localization
import Components

public struct EmojiStyleScene: View {
    private enum Tab: Equatable {
        case emoji, style
    }

    @Environment(\.dismiss) private var dismiss
    
    private let emojiViewSize: Sizing = .image.extraLarge
    @State private var selectedTab: Tab = .emoji
    
    @State private var model: EmojiStyleViewModel

    public init(model: EmojiStyleViewModel) {
        _model = State(initialValue: model)
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                EmojiView(color: model.color, emoji: model.text)
                    .frame(width: emojiViewSize, height: emojiViewSize)

                picker
                    .padding(.horizontal, .medium)
                    .padding(.top, .medium)

                Group {
                    switch selectedTab {
                    case .emoji:
                        emojiListView
                    case .style:
                        colorsView
                    }
                }
                .padding(.horizontal, .medium)
                .padding(.top, .medium)
                
                magicButton
                    .padding(.horizontal, .medium)

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
                spacing: .medium
            ) {
                ForEach(model.emojiList, id: \.self) { item in
                    let view = EmojiView(color: item.color, emoji: item.emoji)
                    NavigationCustomLink(with: view, action: {
                        model.text = item.emoji
                    })
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
                spacing: .medium
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
