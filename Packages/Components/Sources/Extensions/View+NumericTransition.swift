import SwiftUI

public extension View {
    func numericTransition<V: Equatable>(for value: V) -> some View {
        self.numericTransition(for: [value])
    }
    
    func numericTransition<V: Equatable>(for values: [V]) -> some View {
        self
            .contentTransition(.numericText(countsDown: true))
            .animation(.default, value: values)
    }
}
