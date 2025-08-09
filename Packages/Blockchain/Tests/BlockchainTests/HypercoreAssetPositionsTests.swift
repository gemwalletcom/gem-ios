// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import Blockchain

struct HypercoreAssetPositionsTests {
    
    @Test
    func mapToPerpetualPositions() {
        let walletId = "wallet123"
        
        let positions = HypercoreAssetPositions(
            assetPositions: [
                HypercoreAssetPosition(
                    type: .oneWay,
                    position: HypercorePosition(
                        coin: "SOL",
                        szi: "-10.0",
                        leverage: HypercoreLeverage(type: .cross, value: 20),
                        entryPx: "195.39",
                        positionValue: "2029.2",
                        unrealizedPnl: "-75.3",
                        returnOnEquity: "-0.77076616",
                        liquidationPx: "558.9517436098",
                        marginUsed: "101.46",
                        maxLeverage: 20,
                        cumFunding: HypercoreCumulativeFunding(allTime: "-1.3358", sinceOpen: "-1.3")
                    )
                ),
                HypercoreAssetPosition(
                    type: .oneWay,
                    position: HypercorePosition(
                        coin: "BTC",
                        szi: "3.0",
                        leverage: HypercoreLeverage(type: .isolated, value: 10),
                        entryPx: "766.34",
                        positionValue: "2332.2",
                        unrealizedPnl: "33.18",
                        returnOnEquity: "0.1443223634",
                        liquidationPx: nil,
                        marginUsed: "233.22",
                        maxLeverage: 10,
                        cumFunding: HypercoreCumulativeFunding(allTime: "1.686397", sinceOpen: "1.1")
                    )
                )
            ],
            marginSummary: HypercoreMarginSummary(
                accountValue: "1000",
                totalNtlPos: "100",
                totalRawUsd: "100",
                totalMarginUsed: "100"
            ),
            crossMarginSummary: HypercoreMarginSummary(
                accountValue: "1000",
                totalNtlPos: "100",
                totalRawUsd: "100",
                totalMarginUsed: "100"
            ),
            crossMaintenanceMarginUsed: "50",
            withdrawable: "500"
        )
        
        let perpetualPositions = positions.mapToPerpetualPositions(walletId: walletId)
        
        #expect(perpetualPositions.count == 2)
        
        let solPosition = perpetualPositions.first { $0.perpetualId.contains("SOL") }!
        #expect(solPosition.size == -10.0)
        #expect(solPosition.sizeValue == 2029.2)
        #expect(solPosition.leverage == 20)
        #expect(solPosition.marginType == PerpetualMarginType.cross)
        #expect(solPosition.marginAmount == 101.46)
        #expect(solPosition.pnl == -75.3)
        #expect(solPosition.funding == 1.3)
        
        let btcPosition = perpetualPositions.first { $0.perpetualId.contains("BTC") }!
        #expect(btcPosition.size == 3.0)
        #expect(btcPosition.sizeValue == 2332.2)
        #expect(btcPosition.leverage == 10)
        #expect(btcPosition.marginType == PerpetualMarginType.isolated)
        #expect(btcPosition.marginAmount == 233.22)
        #expect(btcPosition.pnl == 33.18)
        #expect(btcPosition.funding == -1.1)
    }
    
    @Test
    func fundingSignReversal() {
        let walletId = "wallet123"
        
        let testCases: [(coin: String, size: String, funding: String, expectedFunding: Float)] = [
            ("BTC", "3.0", "1.5", -1.5),
            ("BNB", "2.0", "-1.0", 1.0),
            ("SOL", "-10.0", "-1.5", 1.5),
            ("ETH", "-5.0", "2.0", 2.0),
        ]
        
        for testCase in testCases {
            let positions = HypercoreAssetPositions(
                assetPositions: [
                    HypercoreAssetPosition(
                        type: .oneWay,
                        position: HypercorePosition(
                            coin: testCase.coin,
                            szi: testCase.size,
                            leverage: HypercoreLeverage(type: .cross, value: 10),
                            entryPx: "100",
                            positionValue: "1000",
                            unrealizedPnl: "0",
                            returnOnEquity: "0",
                            liquidationPx: nil,
                            marginUsed: "100",
                            maxLeverage: 10,
                            cumFunding: HypercoreCumulativeFunding(allTime: testCase.funding, sinceOpen: testCase.funding)
                        )
                    )
                ],
                marginSummary: HypercoreMarginSummary(
                    accountValue: "1000",
                    totalNtlPos: "100",
                    totalRawUsd: "100",
                    totalMarginUsed: "100"
                ),
                crossMarginSummary: HypercoreMarginSummary(
                    accountValue: "1000",
                    totalNtlPos: "100",
                    totalRawUsd: "100",
                    totalMarginUsed: "100"
                ),
                crossMaintenanceMarginUsed: "50",
                withdrawable: "500"
            )
            
            let result = positions.mapToPerpetualPositions(walletId: walletId)
            
            #expect(result.count == 1)
            #expect(result[0].funding == testCase.expectedFunding)
        }
    }
    
    @Test
    func mapToPerpetualBalance() throws {
        let positions = HypercoreAssetPositions(
            assetPositions: [],
            marginSummary: HypercoreMarginSummary(
                accountValue: "5000.50",
                totalNtlPos: "100",
                totalRawUsd: "100",
                totalMarginUsed: "100"
            ),
            crossMarginSummary: HypercoreMarginSummary(
                accountValue: "1000",
                totalNtlPos: "100",
                totalRawUsd: "100",
                totalMarginUsed: "1500.25"
            ),
            crossMaintenanceMarginUsed: "50",
            withdrawable: "2500.75"
        )
        
        let balance = try positions.mapToPerpetualBalance()
        
        #expect(balance.reserved == 1500.25)
        #expect(balance.available == 3500.25)
        #expect(balance.withdrawable == 2500.75)
    }
    
    @Test
    func mapToPerpetualBalanceWithRealData() throws {
        let positions = HypercoreAssetPositions(
            assetPositions: [],
            marginSummary: HypercoreMarginSummary(
                accountValue: "706.364534",
                totalNtlPos: "12013.47849",
                totalRawUsd: "2737.835324",
                totalMarginUsed: "926.155026"
            ),
            crossMarginSummary: HypercoreMarginSummary(
                accountValue: "706.364534",
                totalNtlPos: "12013.47849",
                totalRawUsd: "2737.835324",
                totalMarginUsed: "926.155026"
            ),
            crossMaintenanceMarginUsed: "400.689965",
            withdrawable: "305.674569"
        )
        
        let balance = try positions.mapToPerpetualBalance()
        
        #expect(balance.reserved == 706.364534)
        #expect(balance.available == 0)
        #expect(balance.withdrawable == 305.674569)
    }
}
