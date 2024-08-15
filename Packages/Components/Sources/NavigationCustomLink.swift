import SwiftUI
import Style

public struct NavigationCustomLink<Content: View>: View {
    private let content: Content
    private let action: (@MainActor () -> Void)

    public init(
        with content: Content,
        action: @escaping @MainActor () -> Void
    ) {
        self.content = content
        self.action = action
    }

    public var body: some View {
        Button(action: self.action) {
            HStack {
                content
                    .layoutPriority(1)
                NavigationLink.empty
            }
        }
        .tint(Colors.black)
    }
}
