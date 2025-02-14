// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import PrimitivesComponents
import Components
import Localization

public struct AvatarCustomizationScene: View {
    @State private var model: AvatarCustomizationViewModel
    private var onHeaderAction: HeaderButtonAction?

    private let emojiViewRenderSize = Sizing.image.extraLarge
    private var offset: CGFloat { Sizing.image.extraLarge / (2 * sqrt(2)) }
    
    public init(
        model: AvatarCustomizationViewModel,
        onHeaderAction: HeaderButtonAction?
    ) {
        _model = State(initialValue: model)
        self.onHeaderAction = onHeaderAction
    }

    public var body: some View {
        VStack {
            headerView
                .padding(.bottom, Spacing.extraLarge)
            
            LazyVGrid(
                columns: model.emojiColumns,
                alignment: .center,
                spacing: Spacing.medium
            ) {
                emojiList
            }
            
            Spacer()
        }
        .padding(.horizontal, Spacing.medium)
        .background(Colors.grayBackground)
    }
    
    private var headerView: some View {
        VStack {
            ZStack() {
                AvatarView(
                    walletId: model.wallet.id,
                    size: emojiViewRenderSize
                )
                .padding(.vertical, Spacing.large)
                
                if model.isVisibleClearButton {
                    Button(action: {
                        withAnimation {
                            model.setDefaultAvatar()
                        }
                    }) {
                        Image(systemName: SystemImage.xmark)
                            .foregroundColor(Colors.black)
                            .padding(Spacing.small)
                            .background(Colors.grayVeryLight)
                            .clipShape(Circle())
                            .background(
                                Circle().stroke(Colors.white, lineWidth: Spacing.extraSmall)
                            )
                    }
                    .offset(x: offset, y: -offset)
                    .transition(.opacity)
                }
            }
            
            HeaderButtonsView(
                buttons: model.headerButtons,
                action: onHeaderAction
            )
        }
    }
    
    private var emojiList: some View {
        ForEach(model.emojiList, id: \.self) { value in
            Button(action: {
                withAnimation {
                    model.image = emojiViewForRender(color: value.color, emoji: value.emoji)
                        .render(for: CGSize(width: emojiViewRenderSize, height: emojiViewRenderSize))
                }
            }) {
                Circle()
                    .fill(value.color)
                    .overlay {
                        Text(value.emoji)
                            .font(.system(size: 40))
                            .minimumScaleFactor(0.5)
                    }
            }
            .frame(maxWidth: .infinity)
            .transition(.opacity)
        }
    }
    
    private func emojiViewForRender(color: Color, emoji: String) -> some View {
        EmojiView(color: color, emoji: emoji)
            .frame(width: emojiViewRenderSize, height: emojiViewRenderSize)
    }
}
