// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct QRScannerDisplayView: View {
    private let configuration: QRScannerDisplayConfiguration
    private let scanResult: QRScannerViewWrapper.ScanResult
    @Binding private var isScannerReady: Bool

    init(
        configuration: QRScannerDisplayConfiguration,
        isScannerReady: Binding<Bool>,
        scanResult: @escaping QRScannerViewWrapper.ScanResult
    ) {
        _isScannerReady = isScannerReady
        self.configuration = configuration
        self.scanResult = scanResult
    }

    private var cornerRadius: CGFloat {
        configuration.cornerRadius
    }

    var body: some View {
        GeometryReader { geometry in
            let boxSize = min(geometry.size.width, geometry.size.height) * configuration.squareScale

            ZStack {
                configuration.overlayColor

                QRScannerViewWrapper(
                    isScannerReady: $isScannerReady,
                    scanResult: scanResult
                )
                
                configuration.overlayColor
                    .opacity(configuration.dimmedViewOpacity)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(configuration.overlayColor)
                            .frame(width: boxSize, height: boxSize)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()

                CornerBracketsView(
                    configuration: configuration,
                    boxSize: boxSize,
                    geometrySize: geometry.size
                )
            }
        }
    }
}

#Preview {
    ZStack {
        Color.red
            .ignoresSafeArea()
        QRScannerDisplayView(
            configuration: .default,
            isScannerReady: .constant(true),
            scanResult: {_ in}
        )
    }
}
