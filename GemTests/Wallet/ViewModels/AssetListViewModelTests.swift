import XCTest
@testable import Gem
import Primitives

//TODO: Add separate tests for Price model
//final class AssetListViewModelTests: XCTestCase {
//    func testPriceAmount() {
//        XCTAssertEqual(
//            AssetListViewModel(assetDataModel: .make(assetData: .make(price: Price(price: 10, priceChange: 11.1)))).priceAmount,
//            "$10.0"
//        )
//    }
//
//    func testPriceChange() {
//        XCTAssertEqual(
//            AssetListViewModel(assetData: .make(assetData: .make(price: Price(price: 10, priceChange: 11.1)))).priceChange,
//            "+11.1"
//        )
//
//        XCTAssertEqual(
//            AssetListViewModel(assetData: .make(assetData: .make(price: Price(price: 10, priceChange: -9.1)))).priceChange,
//            "-9.1"
//        )
//    }
//}
//
//extension AssetDataViewModel {
//    static make(assetData: AssetData) -> AssetDataViewModel {
//        return AssetDataViewModel(assetData: assetData)
//    }
//}
//
//extension AssetData {
//    static func make(
//        asset: Asset = .main,
//        balance: Balance = .main,
//        price: Price = .main
//    ) -> AssetData {
//        return AssetData(asset: asset, balance: balance, price: price)
//    }
//}
