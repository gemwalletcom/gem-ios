// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

import SwiftUI
import Primitives

struct AmountNavigationView: View {
    
    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.nodeService) private var nodeService

    let input: AmountInput
    let wallet: Wallet

    @Binding var navigationPath: NavigationPath

    @State private var transferData: TransferData?

    @State private var isPresentingScanner: AmountScene.Field?

    var body: some View {
        AmountScene(
            model: AmounViewModel(
                input: input,
                wallet: wallet,
                walletsService: walletsService,
                stakeService: stakeService
            )
        )
        .navigationDestination(for: $transferData) { data in
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: wallet,
                    keystore: keystore,
                    data: data,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: input.asset.chain),
                    walletsService: walletsService
                )
            )
        }

//        .sheet(item: $isPresentingScanner) { value in
//            ScanQRCodeNavigationStack() {_ in 
//                //onHandleScan($0, for: value)
//            }
//        }

    }
}
