import Foundation
import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    public init(isAnimating: Binding<Bool>, style: UIActivityIndicatorView.Style) {
        _isAnimating = isAnimating
        self.style = style
    }

    public func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: style)
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

private struct ActivityIndicatorOverlay: ViewModifier {
    let isLoading: Bool
    let message: String

    func body(content: Content) -> some View {
        content
            .disabled(isLoading)
            .overlay {
                if isLoading {
                    GeometryReader { geo in
                        VStack(spacing: .small) {
                            Text(message)
                            ActivityIndicator(isAnimating: .constant(true), style: .large)
                        }
                        .padding(.horizontal, .extraLarge)
                        .padding(.vertical, .medium)
                        .background(Color.secondary.colorInvert())
                        .foregroundStyle(.primary)
                        .cornerRadius(20)
                        .position(
                            x: geo.size.width / 2,
                            y: geo.size.height / 2
                        )
                        .transition(.opacity.combined(with: .scale))
                    }
                }
            }
            .animation(.easeInOut(duration: .AnimationDuration.normal), value: isLoading)
    }
}

// MARK: - View Modifier

public extension View {
    func activityIndicator(isLoading: Bool, message: String) -> some View {
        modifier(ActivityIndicatorOverlay(isLoading: isLoading, message: message))
    }
}
