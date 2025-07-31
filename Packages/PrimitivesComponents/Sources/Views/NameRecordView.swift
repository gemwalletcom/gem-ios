// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Components
import SwiftUI
import Style

public struct NameRecordView: View {

    let model: NameRecordViewModel

    @Binding var state: NameRecordState
    @Binding var address: String
    let debounceTimeout = Duration.seconds(1)

    @State var nameResolveTask: Task<NameRecord, any Error>?

    public init(
        model: NameRecordViewModel,
        state: Binding<NameRecordState>,
        address: Binding<String>
    ) {
        self.model = model
        _state = state
        _address = address
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            switch state {
            case .none: EmptyView()
            case .error: Images.NameResolve.error
            case .loading: LoadingView()
            case .complete: Images.NameResolve.success
            }
        }.frame(width: 16, height: 16)
        .onChange(of: address) {
            Task {
                nameResolveTask?.cancel()
                if model.canResolveName(name: address) {
                    state = .loading
                    do {
                        let task = Task.detached { @Sendable in
                            try await Task.sleep(for: debounceTimeout)
                            return try await model.resolveName(name: address)
                        }
                        nameResolveTask = task
                        state = .complete(try await task.value)
                    } catch {
                        if error.isCancelled {
                            return
                        }
                        state = .error
                    }
                } else {
                    state = .none
                }
            }
        }
    }
}