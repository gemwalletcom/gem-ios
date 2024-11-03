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
    public static let delete = "trash"
    public static let checkmark = "checkmark"
    public static let ellipsis = "ellipsis"
    public static let info = "info.circle"
    public static let eyeglasses = "eyeglasses"
    public static let lockOpen = "lock.open"
    public static let plus = "plus"
    public static let eye = "eye.fill"
    public static let searchNoResults = "exclamationmark.magnifyingglass"
    public static let exclamationmarkTriangleFill = "exclamationmark.triangle.fill"
    public static let exclamationmarkTriangle = "exclamationmark.triangle"
    public static let gallery = "photo.artframe"
    public static let photo = "photo"
    public static let xmarkCircle = "xmark.circle.fill"
    public static let xmark = "xmark"
    public static let bell = "bell"
    public static let bellFill = "bell.fill"
    public static let pin = "pin"
    public static let unpin = "pin.slash"
    public static let filter = "line.horizontal.3.decrease.circle"
    public static let filterFill = "line.horizontal.3.decrease.circle.fill"
    public static let book = "book"
    
    // specific to Gem style
    public static let errorOccurred = exclamationmarkTriangleFill
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
        (SystemImage.delete, "Delete"),
        (SystemImage.checkmark, "Checkmark"),
        (SystemImage.ellipsis, "Ellipsis"),
        (SystemImage.info, "Info"),
        (SystemImage.eyeglasses, "Eyeglasses"),
        (SystemImage.lockOpen, "Lock Open"),
        (SystemImage.plus, "Plus"),
        (SystemImage.eye, "Eye"),
        (SystemImage.searchNoResults, "No Results"),
        (SystemImage.errorOccurred, "Error Ocurred"),
        (SystemImage.gallery, "Gallery"),
        (SystemImage.xmarkCircle, "X MarkCircle"),
        (SystemImage.xmark, "X Mark"),
        (SystemImage.bell, "Bell"),
        (SystemImage.pin, "Pin"),
        (SystemImage.unpin, "Unpin"),
        (SystemImage.filter, "Filter"),
        (SystemImage.filterFill, "Filter Fill"),
        (SystemImage.book, "book"),
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
