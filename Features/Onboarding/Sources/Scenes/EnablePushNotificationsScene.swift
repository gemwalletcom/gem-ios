// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Components
import Localization
import PrimitivesComponents

public struct EnablePushNotificationsScene: View {
    @State private var model: EnablePushNotificationsViewModel

    public init(model: EnablePushNotificationsViewModel) {
        _model = State(wrappedValue: model)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: .zero) {
                VStack(spacing: .medium) {
                    Text(Emoji.bell)
                        .font(.system(size: .image.semiLarge))
                        .frame(size: .image.semiExtraLarge)
                        .background(Circle().fill(Colors.grayBackground))

                    VStack(spacing: .small) {
                        Text(model.title)
                            .textStyle(.boldTitle)
                        Text(model.message)
                            .textStyle(.bodySecondary)
                    }
                    .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, .extraLarge)

                Spacer()

                VStack(spacing: Spacing.medium) {
                    StateButton(
                        text: Localized.Settings.enableValue(""),
                        type: .primary(model.buttonState),
                        action: model.onEnable
                    )
                    .frame(maxWidth: .scene.button.maxWidth)
                }
                .padding(.bottom, .scene.bottom)
            }
            .padding(.horizontal, .medium)
            .alertSheet($model.isPresentingAlertMessage)
            .toolbarDismissItem(title: .custom(Localized.Common.skip), placement: .topBarTrailing)
        }
    }
}
