import SwiftUI

@available(iOS 26.0, *)
public struct LiquidGlassModifier: ViewModifier {
    private let tint: Color?
    private let interactive: Bool
    
    public init(tint: Color?, interactive: Bool) {
        self.tint = tint
        self.interactive = interactive
    }
    
    public func body(content: Content) -> some View {
        content
            .glassEffect(.regular.tint(tint).interactive(interactive))
    }
}

public extension View {
    @ViewBuilder
    func liquidGlass<Fallback: View>(
        tint: Color? = nil,
        interactive: Bool = true,
        fallback: (Self) -> Fallback
    ) -> some View {
        if #available(iOS 26.0, *) {
            modifier(LiquidGlassModifier(tint: tint, interactive: interactive))
        } else {
            fallback(self)
        }
    }
    
    @ViewBuilder
    func liquidGlass(
        tint: Color? = nil,
        interactive: Bool = true
    ) -> some View {
        liquidGlass(
            tint: tint,
            interactive: interactive,
            fallback: { $0 }
        )
    }
}
