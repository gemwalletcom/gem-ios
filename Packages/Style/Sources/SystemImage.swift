// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct SystemImage {
    public static let settings = "gearshape"
    public static let qrCode = "qrcode.viewfinder"
    public static let paste = "doc.on.clipboard"
    public static let copy = "doc.on.doc"
    public static let chevronDown = "chevron.down"
    public static let checklist = "checklist.unchecked"
    public static let clear = "multiply.circle.fill"
    public static let hide = "eye.slash.fill"
    public static let list = "list.bullet"
    public static let faceid = "faceid"
    public static let touchid = "touchid"
    public static let network = "network"
    public static let globe = "globe"
    public static let share = "square.and.arrow.up"
    public static let lock = "lock"
    public static let none = ""
    public static let delete = "trash"
    public static let checkmark = "checkmark"
    public static let ellipsis = "ellipsis"
    public static let info = "info.circle"
    public static let eyeglasses = "eyeglasses"
    public static let lockOpen = "lock.open"
    public static let plus = "plus"
    public static let eye = "eye.fill"
    public static let searchNoResults = "exclamationmark.magnifyingglass"
}

// MARK: - Previews

#Preview {
    let symbols = [
        (SystemImage.settings, "Settings"),
        (SystemImage.qrCode, "QR Code"),
        (SystemImage.paste, "Paste"),
        (SystemImage.copy, "Copy"),
        (SystemImage.chevronDown, "Chevron Down"),
        (SystemImage.checklist, "Checklist"),
        (SystemImage.clear, "Clear"),
        (SystemImage.hide, "Hide"),
        (SystemImage.list, "List"),
        (SystemImage.faceid, "Face ID"),
        (SystemImage.touchid, "Touch ID"),
        (SystemImage.network, "Network"),
        (SystemImage.globe, "Globe"),
        (SystemImage.share, "Share"),
        (SystemImage.lock, "Lock"),
        (SystemImage.none, "None"),
        (SystemImage.delete, "Delete"),
        (SystemImage.checkmark, "Checkmark"),
        (SystemImage.ellipsis, "Ellipsis"),
        (SystemImage.info, "Info"),
        (SystemImage.eyeglasses, "Eyeglasses"),
        (SystemImage.lockOpen, "Lock Open"),
        (SystemImage.plus, "Plus"),
        (SystemImage.eye, "Eye"),
        (SystemImage.searchNoResults, "No Results")
    ]

    return List {
        ForEach(symbols, id: \.1) { symbol in
            Section(header: Text(symbol.1)) {
                Image(systemName: symbol.0)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Sizing.list.image, height: Sizing.list.image)
                    .padding(Spacing.extraSmall)
            }
        }
    }
    .listStyle(InsetGroupedListStyle())
    .padding()
}
