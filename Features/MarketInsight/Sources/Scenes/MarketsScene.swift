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
                Text("")
            case .loading:
                LoadingView()
            case .data(let data):
                PriceListItemView(model: data.marketCapViewModel)
            case .error(let error):
                ListItemErrorView(error: error)
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
        .overlay {
            if model.state.isNoData {
                EmptyContentView(model: model.emptyContentModel)
            }
        }
        .navigationTitle(model.title)
    }
}
