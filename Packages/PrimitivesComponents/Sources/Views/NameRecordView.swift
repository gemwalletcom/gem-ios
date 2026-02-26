// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Components
import SwiftUI
import Style

public struct NameRecordView: View {

    let model: NameRecordViewModel

    public init(model: NameRecordViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            switch model.state {
            case .none: EmptyView()
            case .error: Images.NameResolve.error
            case .loading: LoadingView()
            case .complete: Images.NameResolve.success
            }
        }.frame(width: 16, height: 16)
    }
}
