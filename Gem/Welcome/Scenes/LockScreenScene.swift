// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct LockScreenScene: View {
    
    @ObservedObject var lockStateService: LockStateService
    
    var body: some View {
        VStack {
            Spacer()
            VStack() {
                Image(.logo)
                    .resizable()
                    .frame(width: 128, height: 128)
                    .scaledToFit()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Colors.white)
    }
}

//struct LockScreenScene_Previews: PreviewProvider {
//    static var previews: some View {
//        LockScreenScene()
//    }
//}
