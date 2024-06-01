import SwiftUI
import CodeScanner

public struct QRScanner: View {
    
    var action: ((String) -> Void)?
    
    public init(
        action: ((String) -> Void)?
    ) {
        self.action = action
    }
    
    public var body: some View {
        CodeScannerView(codeTypes: [.qr]) { response in
            if case let .success(result) = response {
                action?(result.string)
            }
        }
    }
}
