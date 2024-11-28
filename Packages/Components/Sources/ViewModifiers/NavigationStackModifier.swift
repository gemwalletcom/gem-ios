import Foundation
import SwiftUI

// TODO: - Remove modifier and use native navigationDestination(item: )
struct NavigationStackModifier<Item: Hashable, Destination: View>: ViewModifier {
    let item: Binding<Item?>
    let destination: (Item) -> Destination

    func body(content: Content) -> some View {
        content.navigationDestination(item: item) { scene in
            destination(scene)
        }
    }
}

public extension View {
    func navigationDestination<Item: Hashable, Destination: View>(
        for binding: Binding<Item?>,
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) -> some View {
        self.modifier(NavigationStackModifier(item: binding, destination: destination))
    }
}

public extension Binding where Value == Bool {
    init<Wrapped: Sendable>(bindingOptional: Binding<Wrapped?>) {
        self.init(
            get: {
                bindingOptional.wrappedValue != nil
            },
            set: { newValue in
                guard newValue == false else { return }

                /// We only handle `false` booleans to set our optional to `nil`
                /// as we can't handle `true` for restoring the previous value.
                bindingOptional.wrappedValue = nil
            }
        )
    }
}

// TODO: - move Binding extension somewhere to SwiftUI extensions
extension Binding {
    public func mappedToBool<Wrapped: Sendable>() -> Binding<Bool> where Value == Wrapped? {
        return Binding<Bool>(bindingOptional: self)
    }
}
