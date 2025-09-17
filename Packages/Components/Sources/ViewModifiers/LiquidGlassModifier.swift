import SwiftUI

public struct LiquidGlassModifier: ViewModifier {
    private let tint: Color?
    private let interactive: Bool
    
    public init(tint: Color?, interactive: Bool) {
        self.tint = tint
        self.interactive = interactive
    }
    
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(tint).interactive(interactive))
        } else {
            content
        }
    }
}

public extension View {
    func liquidGlass(
        tint: Color? = nil,
        interactive: Bool = true
    ) -> some View {
        modifier(LiquidGlassModifier(tint: tint, interactive: interactive))
    }
}
