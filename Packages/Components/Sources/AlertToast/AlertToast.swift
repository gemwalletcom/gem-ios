// Adopted from https://github.com/elai950/AlertToast

import SwiftUI
import Combine
import Style

public struct AlertToast: View {

    public let systemImage: String
    public let imageColor: Color
    public let title: String
    public let titleColor: Color?
    public let titleFont: Font?

    public init(
        systemImage: String,
        imageColor: Color,
        title: String,
        titleColor: Color? = nil,
        titleFont: Font? = nil
    ) {
        self.systemImage = systemImage
        self.imageColor = imageColor
        self.title = title
        self.titleColor = titleColor
        self.titleFont = titleFont
    }

    public var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: .medium) {
                Image(systemName: systemImage)
                    .foregroundColor(imageColor)
                
                Text(LocalizedStringKey(title))
                    .font(titleFont ?? Font.headline.bold())
                    .foregroundColor(titleColor)
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, .medium)
            .padding(.vertical, .medium)
            .frame(maxWidth: .scene.content.maxWidth, alignment: .leading)
            .liquidGlass(fallback: { view in
                view
                    .background(BlurView())
                    .cornerRadius(.space10)
            })
            .padding(.horizontal, .medium)
            .padding(.bottom, .medium)
        }
    }
}

public struct AlertToastModifier: ViewModifier {

    @Binding var isPresenting: Bool

    var duration: TimeInterval = 2
    var tapToDismiss: Bool = true
    var offsetY: CGFloat = 0

    var alert: () -> AlertToast

    var onTap: (() -> Void)? = nil
    var completion: (() -> Void)? = nil

    @ViewBuilder
    private func main() -> some View {
        if isPresenting {
            alert()
                .offset(y: offsetY)
                .onTapGesture {
                    onTap?()
                    if tapToDismiss {
                        withAnimation(.spring()) {
                            isPresenting = false
                        }
                    }
                }
                .onDisappear {
                    completion?()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    public func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    main()
                }
                .animation(.spring(), value: isPresenting)
            )
            .task(id: isPresenting) {
                if isPresenting && duration > 0 && duration.isFinite {
                    try? await Task.sleep(for: .seconds(duration))
                    withAnimation(.spring()) {
                        isPresenting = false
                    }
                }
            }
    }
}

public extension View {
    func toast(
        isPresenting: Binding<Bool>,
        duration: TimeInterval = 2,
        tapToDismiss: Bool = true,
        offsetY: CGFloat = 0,
        alert: @escaping () -> AlertToast,
        onTap: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) -> some View {
        modifier(AlertToastModifier(
            isPresenting: isPresenting,
            duration: duration,
            tapToDismiss: tapToDismiss,
            offsetY: offsetY,
            alert: alert,
            onTap: onTap,
            completion: completion
        ))
    }
}
