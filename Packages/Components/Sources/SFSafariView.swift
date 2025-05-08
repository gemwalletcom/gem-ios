// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SafariServices
import SwiftUI

public struct SFSafariView: UIViewControllerRepresentable {
    let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.barCollapsingEnabled = false
        return SFSafariViewController(url: url, configuration: configuration)
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
