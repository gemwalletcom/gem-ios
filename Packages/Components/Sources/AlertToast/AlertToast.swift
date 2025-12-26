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

    var duration: Double = 2
    var tapToDismiss: Bool = true

    var alert: () -> AlertToast

    var onTap: (() -> Void)? = nil
    var completion: (() -> Void)? = nil

    @State private var workItem: DispatchWorkItem?

    @ViewBuilder
    private func main() -> some View {
        if isPresenting {
            alert()
                .onTapGesture {
                    onTap?()
                    if tapToDismiss {
                        withAnimation(.spring()) {
                            workItem?.cancel()
                            isPresenting = false
                            workItem = nil
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
            .onChange(of: isPresenting) { _, presented in
                if presented {
                    onAppearAction()
                }
            }
    }

    private func onAppearAction() {
        guard workItem == nil else { return }

        if duration > 0 {
            workItem?.cancel()

            let task = DispatchWorkItem {
                withAnimation(.spring()) {
                    isPresenting = false
                    workItem = nil
                }
            }
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
        }
    }
}

public extension View {
    func toast(
        isPresenting: Binding<Bool>,
        duration: Double = 2,
        tapToDismiss: Bool = true,
        alert: @escaping () -> AlertToast,
        onTap: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) -> some View {
        modifier(AlertToastModifier(
            isPresenting: isPresenting,
            duration: duration,
            tapToDismiss: tapToDismiss,
            alert: alert,
            onTap: onTap,
            completion: completion
        ))
    }
}
