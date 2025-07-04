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
    func testAmountValueText() {
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

        #expect(model.amountValueText.contains(asset.symbol))
        #expect(!model.amountValueText.isEmpty)
        #expect(model.amountValueText == "1 BTC")
    }
    
    @Test
    func testSentAmountValueText() {
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

        #expect(model.amountValueText.contains(asset.symbol))
        #expect(!model.amountValueText.isEmpty)
        #expect(model.amountValueText == "-1 BTC")
    }

    @Test
    func testAmountFiatValueText() {
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

        #expect(model.amountFiatValueText != nil)
        if let fiatText = model.amountFiatValueText {
            #expect(!fiatText.isEmpty)
            #expect(fiatText == "$1.50")
        }
    }

    @Test
    func testFeeValueText() {
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

        #expect(model.feeValueText != nil)
        #expect(model.feeValueText!.contains(feeAsset.symbol))
        #expect(model.feeValueText! == "0.10 BTC")
    }

    @Test
    func testFeeFiatValueText() {
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

        #expect(model.feeFiatValueText != nil)
        #expect(!model.feeFiatValueText!.isEmpty)
        #expect(model.feeFiatValueText! == "$0.05")
    }

    @Test
    func testHeaderTypeAmount() {
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
        let header = model.headerType(input: .amount(showFiatSubtitle: true))
        guard case .amount(let title, let subtitle) = header else {
            Issue.record("Expected header type .amount")
            return
        }
    
        #expect(title == model.amountValueText)
        #expect(subtitle == model.amountFiatValueText)
        #expect(title == "1 BTC")
        #expect(subtitle == "$1.50")
    }

    @Test
    func testHeaderTypeNFT() {
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
    func testHeaderTypeSwap() {
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
    func testAmountFiatValueTextNilWhenAssetPriceIsNil() {
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

        #expect(model.amountFiatValueText == nil)
    }

    @Test
    func testFeeValueTextNilWhenFeeValueIsNil() {
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

        #expect(model.feeValueText == nil)
    }

    @Test
    func testFeeFiatValueTextNilWhenFeeAssetPriceIsNil() {
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

        #expect(model.feeFiatValueText == nil)
    }

    @Test
    func testHeaderTypeAmountWithoutFiatSubtitle() {
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
        let header = model.headerType(input: .amount(showFiatSubtitle: false))
        guard case .amount(let title, let subtitle) = header else {
            Issue.record("Expected header type .amount")
            return
        }

        #expect(title == model.amountValueText)
        #expect(subtitle == nil || subtitle?.isEmpty == true)
    }
}
