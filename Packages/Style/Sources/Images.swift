// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct Images {
    public struct Logo {
        public static let logo = Image(.logo)
        public static let logoDark = Image(.logoDark)
    }

    public struct Chains {
        public static let aptos = Image(.aptos)
        public static let arbitrum = Image(.arbitrum)
        public static let avalanchec = Image(.avalanchec)
        public static let base = Image(.base)
        public static let bitcoin = Image(.bitcoin)
        public static let bitcoincash = Image(.bitcoincash)
        public static let blast = Image(.blast)
        public static let celestia = Image(.celestia)
        public static let celo = Image(.celo)
        public static let cosmos = Image(.cosmos)
        public static let doge = Image(.doge)
        public static let ethereum = Image(.ethereum)
        public static let fantom = Image(.fantom)
        public static let gnosis = Image(.gnosis)
        public static let injective = Image(.injective)
        public static let linea = Image(.linea)
        public static let litecoin = Image(.litecoin)
        public static let manta = Image(.manta)
        public static let mantle = Image(.mantle)
        public static let near = Image(.near)
        public static let world = Image(.world)
        public static let noble = Image(.noble)
        public static let opbnb = Image(.smartchain)
        public static let optimism = Image(.optimism)
        public static let osmosis = Image(.osmosis)
        public static let polygon = Image(.polygon)
        public static let sei = Image(.sei)
        public static let smartchain = Image(.smartchain)
        public static let solana = Image(.solana)
        public static let sui = Image(.sui)
        public static let thorchain = Image(.thorchain)
        public static let ton = Image(.ton)
        public static let tron = Image(.tron)
        public static let xrp = Image(.xrp)
        public static let zksync = Image(.zksync)
        public static let stellar = Image(.stellar)
        public static let sonic = Image(.sonic)
        public static let algorand = Image(.algorand)
        public static let polkadot = Image(.polkadot)
    }
    
    public struct SwapProviders {
        public static let uniswap = Image(.uniswap)
        public static let pancakeswap = Image(.pancakeswap)
        public static let across = Image(.across)
        public static let cetus = Image(.cetus)
        public static let jupiter = Image(.jupiter)
        public static let mayan = Image(.mayan)
        public static let stonfi = Image(.stonfi)
        public static let thorchain = Image(.thorchain)
        public static let orca = Image(.orca)
        public static let stargate = Image(.stargate)
        public static let raydium = Image(.raydium)
    }

    public struct Fiat {
        public static let kado = Image(.kado)
        public static let moonpay = Image(.moonpay)
        public static let transak = Image(.transak)
        public static let banxa = Image(.banxa)
        public static let mercuryo = Image(.mercuryo)
        public static let ramp = Image(.ramp)
    }

    public struct Actions {
        public static let send = Image(.send)
        public static let swap = Image(.swap)
        public static let receive = Image(.receive)
        public static let buy = Image(.buy)
        public static let manage = Image(.manage)
        public static let sell = Image(.sell)
    }

    public struct Settings {
        public static let priceAlerts = Image(.settingsPriceAlerts)
        public static let currency = Image(.settingsCurrency)
        public static let rate = Image(.settingsRate)
        public static let developer = Image(.settingsDeveloper)
        public static let security = Image(.settingsSecurity)
        public static let gem = Image(.settingsGem)
        public static let support = Image(.settingsSupport)
        public static let helpCenter = Image(.settingsHelpCenter)
        public static let version = Image(.settingsVersion)
        public static let language = Image(.settingsLanguage)
        public static let wallets = Image(.settingsWallets)
        public static let networks = Image(.settingsNetworks)
        public static let walletConnect = Image(.settingsWalletConnect)
        public static let notifications = Image(.settingsNotifications)
    }

    public struct Social {
        public static let github = Image(.github)
        public static let telegram = Image(.telegram)
        public static let coingecko = Image(.coingecko)
        public static let instagram = Image(.instagram)
        public static let x = Image(.x)
        public static let discord = Image(.discord)
        public static let reddit = Image(.reddit)
        public static let youtube = Image(.youtube)
        public static let website = Image(.website)
        public static let facebook = Image("") //TODO
    }

    public struct Tags {
        public static let settings = Image(.tabSettings)
        public static let activity = Image(.tabActivity)
        public static let wallet = Image(.tabWallet)
    }

    public struct Transaction {
        public static let outgoing = Image(.transferOutgoing)
        public static let incoming = Image(.transferIncoming)

        public struct State {
            public static let pending = Image(.transactionStatePending)
            public static let error = Image(.transactionStateError)
            public static let success = Image(.transactionStateSuccess)
        }
    }

    public struct Wallets {
        public static let edit = Image(.edit)
        public static let create = Image(.create)
        public static let `import` = Image(.import)
        public static let watch = Image(.watch)
        public static let selected = Image(.selected)
    }

    public struct NameResolve {
        public static let success = Image(.nameResolveSuccess)
        public static let error = Image(.nameResolveError)
    }
    
    public struct Info {
        public static let networkFee = Image(.networkFee)
    }
}

// MARK: - Preview

#Preview {
    let imageCategories = [
        ("Logo", [
            (Images.Logo.logo, "Logo"),
            (Images.Logo.logoDark, "Logo Dark")
        ]),
        ("Chains", [
            (Images.Chains.aptos, "Aptos"),
            (Images.Chains.arbitrum, "Arbitrum"),
            (Images.Chains.avalanchec, "Avalanche C"),
            (Images.Chains.base, "Base"),
            (Images.Chains.bitcoin, "Bitcoin"),
            (Images.Chains.blast, "Blast"),
            (Images.Chains.celestia, "Celestia"),
            (Images.Chains.celo, "Celo"),
            (Images.Chains.cosmos, "Cosmos"),
            (Images.Chains.doge, "Doge"),
            (Images.Chains.ethereum, "Ethereum"),
            (Images.Chains.fantom, "Fantom"),
            (Images.Chains.gnosis, "Gnosis"),
            (Images.Chains.injective, "Injective"),
            (Images.Chains.linea, "Linea"),
            (Images.Chains.litecoin, "Litecoin"),
            (Images.Chains.manta, "Manta"),
            (Images.Chains.mantle, "Mantle"),
            (Images.Chains.near, "Near"),
            (Images.Chains.noble, "Noble"),
            (Images.Chains.opbnb, "OpBNB"),
            (Images.Chains.optimism, "Optimism"),
            (Images.Chains.osmosis, "Osmosis"),
            (Images.Chains.polygon, "Polygon"),
            (Images.Chains.sei, "Sei"),
            (Images.Chains.smartchain, "Smart Chain"),
            (Images.Chains.solana, "Solana"),
            (Images.Chains.sui, "Sui"),
            (Images.Chains.thorchain, "Thorchain"),
            (Images.Chains.ton, "Ton"),
            (Images.Chains.tron, "Tron"),
            (Images.Chains.xrp, "XRP"),
            (Images.Chains.zksync, "zkSync")
        ]),
        ("Fiat", [
            (Images.Fiat.kado, "Kado"),
            (Images.Fiat.moonpay, "Moonpay"),
            (Images.Fiat.transak, "Transak"),
            (Images.Fiat.banxa, "Banxa"),
            (Images.Fiat.mercuryo, "Mercuryo"),
            (Images.Fiat.ramp, "Ramp")
        ]),
        ("Actions", [
            (Images.Actions.send, "Send"),
            (Images.Actions.swap, "Swap"),
            (Images.Actions.receive, "Receive"),
            (Images.Actions.buy, "Buy"),
            (Images.Actions.manage, "Manage")
        ]),
        ("Settings", [
            (Images.Settings.priceAlerts, "Price Alerts"),
            (Images.Settings.currency, "Currency"),
            (Images.Settings.rate, "Rate"),
            (Images.Settings.developer, "Developer"),
            (Images.Settings.security, "Security"),
            (Images.Settings.gem, "Gem"),
            (Images.Settings.support, "Support"),
            (Images.Settings.helpCenter, "Help Center"),
            (Images.Settings.version, "Version"),
            (Images.Settings.language, "Language"),
            (Images.Settings.wallets, "Wallets"),
            (Images.Settings.networks, "Networks"),
            (Images.Settings.walletConnect, "WalletConnect"),
            (Images.Settings.notifications, "Notifications")
        ]),
        ("Social", [
            (Images.Social.github, "GitHub"),
            (Images.Social.telegram, "Telegram"),
            (Images.Social.coingecko, "CoinGecko"),
            (Images.Social.instagram, "Instagram"),
            (Images.Social.x, "X (Twitter)"),
            (Images.Social.discord, "Discord"),
            (Images.Social.reddit, "Reddit"),
            (Images.Social.youtube, "YouTube")
        ]),
        ("Tags", [
            (Images.Tags.settings, "Settings"),
            (Images.Tags.activity, "Activity"),
            (Images.Tags.wallet, "Wallet")
        ]),
        ("Transaction", [
            (Images.Transaction.outgoing, "Outgoing"),
            (Images.Transaction.incoming, "Incoming"),
            (Images.Transaction.State.pending, "Pending"),
            (Images.Transaction.State.error, "Error"),
            (Images.Transaction.State.success, "Success")
        ]),
        ("Wallets", [
            (Images.Wallets.edit, "Edit"),
            (Images.Wallets.create, "Create"),
            (Images.Wallets.import, "Import"),
            (Images.Wallets.watch, "Watch"),
            (Images.Wallets.selected, "Selected")
        ]),
        ("Name Resolve", [
            (Images.NameResolve.success, "Success"),
            (Images.NameResolve.error, "Error")
        ])
    ]

    return List {
        ForEach(imageCategories, id: \.0) { category in
            Section(header: Text(category.0)) {
                ForEach(category.1.indices, id: \.self) { index in
                    HStack {
                        category.1[index].0
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .padding(4) // Adjust padding as needed
                        Text(category.1[index].1)
                    }
                    .listRowBackground(Colors.greenLight)
                }
            }
        }
    }
    .padding()
}
