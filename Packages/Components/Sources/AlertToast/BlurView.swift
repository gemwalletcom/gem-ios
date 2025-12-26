// Adopted from https://github.com/elai950/AlertToast

import SwiftUI

struct BlurView: UIViewRepresentable {
    typealias UIViewType = UIVisualEffectView

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: .systemMaterial)
    }
}
