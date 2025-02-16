// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import PrimitivesComponents
import Components
import Localization

public struct WalletImageScene: View {
    @State private var model: WalletImageViewModel
    private var onHeaderAction: HeaderButtonAction?
    
    public init(
        model: WalletImageViewModel,
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
                    size: model.emojiViewRenderSize
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
                    .offset(x: model.offset, y: -model.offset)
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
                    model.setAvatarImage(color: value.color.uiColor, text: value.emoji)
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
}
