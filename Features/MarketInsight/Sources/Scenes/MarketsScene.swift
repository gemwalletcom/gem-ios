import Foundation
import SwiftUI
import Components
import Localization

public struct MarketsScene: View {
    
    @State private var model: MarketsViewModel
    
    public init(
        model: MarketsViewModel
    ) {
        _model = State(initialValue: model)
    }
    
    public var body: some View {
        List {
            ListItemView(
                title: Localized.Asset.marketCap,
                subtitle: "1.1T"
            )
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
