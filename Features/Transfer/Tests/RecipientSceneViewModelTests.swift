// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import WalletServiceTestKit
import NameServiceTestKit
import Components
import Formatters
@testable import Transfer

@MainActor
struct RecipientSceneViewModelTests {
    
    @Test
    func tittle() {
        #expect(RecipientSceneViewModel.mock().tittle == "Recipient")
    }
    
    @Test
    func recipientField() {
        #expect(RecipientSceneViewModel.mock().recipientField == "Address or Name")
    }
    
    @Test
    func memoField() {
        #expect(RecipientSceneViewModel.mock().memoField == "Memo")
    }
    
    @Test
    func actionButtonTitle() {
        #expect(RecipientSceneViewModel.mock().actionButtonTitle == "Continue")
    }
    
    @Test
    func showMemo() {
        #expect(RecipientSceneViewModel.mock(asset: .mock(id: AssetId(chain: .cosmos, tokenId: nil))).showMemo == true)
        #expect(RecipientSceneViewModel.mock(asset: .mock(id: AssetId(chain: .ton, tokenId: nil))).showMemo == true)
        #expect(RecipientSceneViewModel.mock(asset: .mock(id: AssetId(chain: .bitcoin, tokenId: nil))).showMemo == false)
        #expect(RecipientSceneViewModel.mock(asset: .mockEthereum()).showMemo == false)
    }
    
    @Test
    func shouldShowInputActions() {
        let model = RecipientSceneViewModel.mock()
        #expect(model.shouldShowInputActions == true)
        
        model.addressInputModel.text = "0x123"
        #expect(model.shouldShowInputActions == false)
    }
    
    @Test
    func actionButtonState() {
        let model = RecipientSceneViewModel.mock()

        #expect(model.actionButtonState == .disabled)
        
        model.addressInputModel.text = "0x1234567890123456789012345678901234567890"
        _ = model.addressInputModel.update()

        #expect(model.actionButtonState == .normal)
        
        model.addressInputModel.text = "invalid"
        _ = model.addressInputModel.update()

        #expect(model.actionButtonState == .disabled)

        model.nameResolveState = .loading
        #expect(model.actionButtonState == .disabled)
        
        model.nameResolveState = .complete(NameRecord.mock())
        #expect(model.actionButtonState == .normal)
    }
    
    @Test
    func getRecipientScanResult_transferData() throws {
        let asset = Asset.mockEthereum()
        let model = RecipientSceneViewModel.mock(asset: asset, type: .mockAsset(asset))
        
        let payment = PaymentScanResult(
            address: "0x1234567890123456789012345678901234567890",
            amount: "1",
            memo: nil
        )
        
        do {
            let result = try model.getRecipientScanResult(payment: payment)
            
            switch result {
            case .transferData(let data):
                #expect(data.recipientData.recipient.address == payment.address)
                #expect(data.canChangeValue == false)
            case .recipient:
                Issue.record("Expected transferData but got recipient")
            }
        } catch {
            // If the formatter throws an error, we can still test the recipient case
            Issue.record("Formatter threw error: \(error)")
        }
    }
    
    @Test
    func getRecipientScanResult_recipient() throws {
        let model = RecipientSceneViewModel.mock()
        
        let payment = PaymentScanResult(
            address: "0x123",
            amount: nil,
            memo: "test memo"
        )
        
        let result = try model.getRecipientScanResult(payment: payment)
        
        switch result {
        case .recipient(let address, let memo, let amount):
            #expect(address == payment.address)
            #expect(memo == payment.memo)
            #expect(amount == payment.amount)
        case .transferData:
            Issue.record("Expected recipient but got transferData")
        }
    }
}

// MARK: - Mocks

extension RecipientSceneViewModel {
    static func mock(
        wallet: Wallet = .mock(),
        asset: Asset = .mockEthereum(),
        type: RecipientAssetType = .mockAsset(),
        onRecipientDataAction: RecipientDataAction = nil,
        onTransferAction: TransferDataAction = nil
    ) -> RecipientSceneViewModel {
        RecipientSceneViewModel(
            wallet: wallet,
            asset: asset,
            walletService: .mock(),
            nameService: .mock(),
            type: type,
            onRecipientDataAction: onRecipientDataAction,
            onTransferAction: onTransferAction
        )
    }
}

