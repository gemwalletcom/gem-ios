// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

extension DeviceLayoutState {
    struct DeviceLayout: Equatable {
        public let size: CGSize
        public let safeArea: EdgeInsets
        public let sizeClass: UserInterfaceSizeClass?
        public let orientation: DeviceLayoutState.Orientation
    }

    enum Orientation: Equatable {
        static var current: Orientation {
            switch UIDevice.current.orientation {
            case .portrait, .portraitUpsideDown:
                return .portrait
            case .landscapeLeft, .landscapeRight:
                return .landscape
            default:
                guard let screenSize = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size else {
                    fatalError("window scene not available")
                }
                return screenSize.height < screenSize.width ? .landscape : .portrait
            }
        }

        case unknown
        case landscape
        case portrait

        var isLandscape: Bool { self == .landscape }
        var isPortrait: Bool { self == .portrait }
    }
}
