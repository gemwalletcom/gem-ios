// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import BigInt
import PrimitivesTestKit

@testable import PrimitivesComponents

struct TransactionInfoModelTests {
    let asset = Asset.mock()
    let feeAsset = Asset.mock()
    let assetPrice = Price.mock(price: 1.5)
    let feeAssetPrice = Price.mock(price: 0.5)
    let value = BigInt(100_000_000)
    let feeValue = BigInt(10_000_000)

    @Test
    func amountDisplay() {
        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: assetPrice,
            feeAsset: feeAsset,
            feeAssetPrice: feeAssetPrice,
            value: value,
            feeValue: feeValue,
            direction: .incoming
        )

        let display = model.amountDisplay()
        #expect(display.amount.text.contains(asset.symbol))
        #expect(!display.amount.text.isEmpty)
        #expect(display.amount.text == "+1 BTC")
    }
    
    @Test
    func amountDisplayOutgoing() {
        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: assetPrice,
            feeAsset: feeAsset,
            feeAssetPrice: feeAssetPrice,
            value: value,
            feeValue: feeValue,
            direction: .outgoing
        )

        let display = model.amountDisplay()
        #expect(display.amount.text.contains(asset.symbol))
        #expect(!display.amount.text.isEmpty)
        #expect(display.amount.text == "-1 BTC")
    }

    @Test
    func amountDisplayFiat() {
        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: assetPrice,
            feeAsset: feeAsset,
            feeAssetPrice: feeAssetPrice,
            value: value,
            feeValue: feeValue,
            direction: nil
        )

        let display = model.amountDisplay()
        #expect(display.fiat != nil)
        #expect(display.fiat?.text == "$1.50")
    }

    @Test
    func feeDisplay() {
        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: assetPrice,
            feeAsset: feeAsset,
            feeAssetPrice: feeAssetPrice,
            value: value,
            feeValue: feeValue,
            direction: .incoming
        )

        #expect(model.feeDisplay != nil)
        #expect(model.feeDisplay!.amount.text.contains(feeAsset.symbol))
        #expect(model.feeDisplay!.amount.text == "0.10 BTC")
    }

    @Test
    func feeDisplayFiat() {
        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: assetPrice,
            feeAsset: feeAsset,
            feeAssetPrice: feeAssetPrice,
            value: value,
            feeValue: feeValue,
            direction: nil
        )

        #expect(model.feeDisplay != nil)
        #expect(model.feeDisplay!.fiat != nil)
        #expect(model.feeDisplay!.fiat!.text == "$0.05")
    }

    @Test
    func headerTypeAmount() {
        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: assetPrice,
            feeAsset: feeAsset,
            feeAssetPrice: feeAssetPrice,
            value: value,
            feeValue: feeValue,
            direction: .incoming
        )
        let header = model.headerType(input: .amount(showFiat: true))
        guard case .amount(let display) = header else {
            Issue.record("Expected header type .amount")
            return
        }
    
        #expect(display.amount.text == "+1 BTC")
        #expect(display.fiat?.text == "$1.50")
    }

    @Test
    func headerTypeNFT() {
        let nftAsset = NFTAsset.mock()
        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: assetPrice,
            feeAsset: feeAsset,
            feeAssetPrice: feeAssetPrice,
            value: value,
            feeValue: feeValue,
            direction: nil
        )

        let header = model.headerType(input: .nft(name: nftAsset.name, id: nftAsset.id))
        guard case .nft(let name, _) = header else {
            Issue.record("Expected header type .nft")
            return
        }

        #expect(name == nftAsset.name)
    }

    @Test
    func headerTypeSwap() {
        let swapMetadata = SwapHeaderInput(
            from: AssetValuePrice(
                asset: asset,
                value: value,
                price: assetPrice
            ),
            to: AssetValuePrice(
                asset: feeAsset,
                value: feeValue,
                price: feeAssetPrice
            )
        )

        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: assetPrice,
            feeAsset: feeAsset,
            feeAssetPrice: feeAssetPrice,
            value: value,
            feeValue: feeValue,
            direction: nil
        )

        let header = model.headerType(input: .swap(swapMetadata))
        guard case .swap(let fromField, let toField) = header else {
            Issue.record("Expected header type .swap")
            return
        }

        #expect(fromField.amount.contains(asset.symbol))
        #expect(toField.amount.contains(feeAsset.symbol))
        #expect(fromField.amount == "1.00 BTC")
        #expect(toField.amount == "0.10 BTC")
    }

    @Test
    func amountDisplayFiatNilWhenAssetPriceIsNil() {
        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: nil,
            feeAsset: feeAsset,
            feeAssetPrice: feeAssetPrice,
            value: value,
            feeValue: feeValue,
            direction: nil
        )

        let display = model.amountDisplay()
        #expect(display.fiat == nil)
    }

    @Test
    func feeDisplayNilWhenFeeValueIsNil() {
        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: assetPrice,
            feeAsset: feeAsset,
            feeAssetPrice: feeAssetPrice,
            value: value,
            feeValue: nil,
            direction: nil
        )

        #expect(model.feeDisplay == nil)
    }

    @Test
    func feeDisplayFiatNilWhenFeeAssetPriceIsNil() {
        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: assetPrice,
            feeAsset: feeAsset,
            feeAssetPrice: nil,
            value: value,
            feeValue: feeValue,
            direction: nil
        )

        #expect(model.feeDisplay?.fiat == nil)
    }

    @Test
    func headerTypeAmountWithoutFiat() {
        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: assetPrice,
            feeAsset: feeAsset,
            feeAssetPrice: feeAssetPrice,
            value: value,
            feeValue: feeValue,
            direction: .incoming
        )
        let header = model.headerType(input: .amount(showFiat: false))
        guard case .amount(let display) = header else {
            Issue.record("Expected header type .amount")
            return
        }

        #expect(display.amount.text == "+1 BTC")
        #expect(display.fiat == nil)
    }
}
