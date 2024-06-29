// from https://github.com/elai950/AlertToast

import SwiftUI
import UIKit

#if os(macOS)
@available(macOS 11, *)
struct AlertToastActivityIndicator: NSViewRepresentable {
    
    func makeNSView(context: NSViewRepresentableContext<AlertToastActivityIndicator>) -> NSProgressIndicator {
        let nsView = NSProgressIndicator()
        
        nsView.isIndeterminate = true
        nsView.style = .spinning
        nsView.startAnimation(context)
        
        return nsView
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<AlertToastActivityIndicator>) {
    }
}
#else
@available(iOS 13, *)
struct AlertToastActivityIndicator: UIViewRepresentable {

    func makeUIView(context: UIViewRepresentableContext<AlertToastActivityIndicator>) -> UIActivityIndicatorView {
        
        let progressView = UIActivityIndicatorView(style: .large)
        progressView.startAnimating()
        
        return progressView
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<AlertToastActivityIndicator>) {
    }
}
#endif
