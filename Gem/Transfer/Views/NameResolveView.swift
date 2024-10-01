// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components

enum NameRecordState {
    case none
    case loading
    case error
    case complete(NameRecord)
}

extension NameRecordState {
    var result: NameRecord? {
        switch self {
        case .complete(let result):
            return result
        default:
            return .none
        }
    }
}

struct NameRecordView: View {
    
    let model: NameRecordViewModel
    
    @Binding var state: NameRecordState
    @Binding var address: String
    let debounceTimeout = Duration.seconds(1)
    
    @State var nameResolveTask: Task<NameRecord, any Error>?

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            switch state {
            case .none:
                EmptyView()
            case .error:
                Image(.nameResolveError)
            case .loading:
                LoadingView()
            case .complete:
                Image(.nameResolveSuccess)
            }
        }.frame(width: 16, height: 16)
        .onChange(of: address) {
            Task {
                nameResolveTask?.cancel()
                
                if model.canResolveName(name: address) {
                    state = .loading
                    do {
                        let task = Task.detached {
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

