// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import InfoSheet
import Localization
import Components

public struct EnablePushNotificationsScene: View {
    @State private var model: EnablePushNotificationsViewModel

    public init(model: EnablePushNotificationsViewModel) {
        _model = State(wrappedValue: model)
    }

    public var body: some View {
        InfoSheetScene(model: model.infoSheetModel)
            .alertSheet($model.isPresentingAlertMessage)
    }
}
