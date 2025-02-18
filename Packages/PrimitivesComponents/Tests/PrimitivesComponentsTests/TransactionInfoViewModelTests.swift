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
            feeValue: feeValue
        )
        #expect(model.amountValueText.contains(asset.symbol))
        #expect(!model.amountValueText.isEmpty)
        #expect(model.amountValueText == "1 BTC")
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
            feeValue: feeValue
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
            feeValue: feeValue
        )
        #expect(model.feeValueText != nil)
        if let feeText = model.feeValueText {
            #expect(feeText.contains(feeAsset.symbol))
            #expect(feeText == "0.10 BTC")
        }
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
            feeValue: feeValue
        )
        #expect(model.feeFiatValueText != nil)
        if let feeFiatText = model.feeFiatValueText {
            #expect(!feeFiatText.isEmpty)
            #expect(feeFiatText == "$0.05")
        }
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
            feeValue: feeValue
        )
        let header = model.headerType(input: .amount(showFiatSubtitle: true))
        switch header {
        case .amount(let title, let subtitle):
            #expect(title == model.amountValueText)
            #expect(subtitle == model.amountFiatValueText)
            #expect(title == "1 BTC")
            #expect(subtitle == "$1.50")
        default:
            Issue.record("Expected header type .amount")
        }
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
            feeValue: feeValue
        )
        let header = model.headerType(input: .nft(nftAsset))
        switch header {
        case .nft(let name, _):
            #expect(name == asset.name)
        default:
            Issue.record("Engine is not electric")
        }
    }

    @Test
    func testHeaderTypeSwap() {
        let swapMetadata = TransacitonHeaderInputType.SwapMetadata(
            fromAsset: asset,
            fromValue: value,
            fromPrice: assetPrice,
            toAsset: feeAsset,
            toValue: feeValue,
            toPrice: feeAssetPrice
        )
        let model = TransactionInfoViewModel(
            currency: "USD",
            asset: asset,
            assetPrice: assetPrice,
            feeAsset: feeAsset,
            feeAssetPrice: feeAssetPrice,
            value: value,
            feeValue: feeValue
        )
        let header = model.headerType(input: .swap(swapMetadata))
        switch header {
        case .swap(let fromField, let toField):
            #expect(fromField.amount.contains(asset.symbol))
            #expect(toField.amount.contains(feeAsset.symbol))
            #expect(fromField.amount == "1.00 BTC")
            #expect(toField.amount == "0.10 BTC")
        default:
            Issue.record("Expected header type .swap")
        }
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
            feeValue: feeValue
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
            feeValue: nil
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
            feeValue: feeValue
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
            feeValue: feeValue
        )
        let header = model.headerType(input: .amount(showFiatSubtitle: false))
        switch header {
        case .amount(let title, let subtitle):
            #expect(title == model.amountValueText)
            #expect(subtitle == nil || subtitle?.isEmpty == true)
        default:
            Issue.record("Expected header type .amount")
        }
    }
}
