import Foundation
import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    public func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

public struct ActivityIndicatorModifier: AnimatableModifier {
    
    let message: String
    var isLoading: Bool

    public init(
        message: String,
        isLoading: Bool
    ) {
        self.message = message
        self.isLoading = isLoading
    }

    public func body(content: Content) -> some View {
        ZStack {
            if isLoading {
                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        content
                            .disabled(self.isLoading)
                        //    .blur(radius: self.isLoading ? 3 : 0)
                        VStack {
                            Text(message)
                            ActivityIndicator(isAnimating: .constant(true), style: .large)
                        }
                        .frame(width: geometry.size.width / 2,
                               height: geometry.size.height / 5)
                        .background(Color.secondary.colorInvert())
                        .foregroundColor(Color.primary)
                        .cornerRadius(20)
                        .opacity(self.isLoading ? 1 : 0)
                        .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                    }
                }
            } else {
                content
            }
        }
    }
}

// MARK: - View Modifier

public extension View {
    func activityIndicator(isLoading: Bool, message: String) -> some View {
        self.modifier(ActivityIndicatorModifier(message: message, isLoading: isLoading))
    }
}
