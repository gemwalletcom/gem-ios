// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import Style
import PrimitivesComponents
import Components

struct FullMessageScene: View {
    @State private var showShareSheet = false

    let model: FullMessageViewModel
    
    var body: some View {
        ScrollView {
            Text(model.displayMessage)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .dismissToolbarItem(title: .cancel, placement: .topBarLeading)
        .customToolbarItem(placement: .topBarTrailing, content: {
            Button {
                showShareSheet.toggle()
            } label: {
                Images.System.share
            }
        })
        .background(Colors.grayBackground)
        .navigationTitle(Localized.SignMessage.message)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [model.displayMessage])
        }
    }
}
