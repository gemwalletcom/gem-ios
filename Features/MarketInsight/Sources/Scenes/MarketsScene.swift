import Foundation
import SwiftUI
import Components
import Localization
import PrimitivesComponents

public struct MarketsScene: View {
    
    @State private var model: MarketsSceneViewModel
    
    public init(
        model: MarketsSceneViewModel
    ) {
        _model = State(initialValue: model)
    }
    
    public var body: some View {
        List {
            switch model.state {
            case .noData:
                EmptyView()
            case .loading:
                EmptyView()
            case .data(let data):
                PriceListItemView(model: data.marketCapViewModel)
            case .error:
                EmptyView()
            }
            
        }
        .refreshable {
            await model.fetch()
        }
        .onAppear() {
            Task {
                await model.fetch()
            }
        }
        .navigationTitle(model.title)
    }
}
