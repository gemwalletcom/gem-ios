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
    struct SystemImageView: View {
        let imageName: String
        let symbolName: String

        var body: some View {
            VStack {
                if !imageName.isEmpty {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .padding()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text("None")
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                }
                Text(symbolName)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding()
        }
    }

    let symbols = [
        (SystemImage.settings, "settings"),
        (SystemImage.qrCode, "qrCode"),
        (SystemImage.paste, "paste"),
        (SystemImage.copy, "copy"),
        (SystemImage.chevronDown, "chevronDown"),
        (SystemImage.checklist, "checklist"),
        (SystemImage.clear, "clear"),
        (SystemImage.hide, "hide"),
        (SystemImage.list, "list"),
        (SystemImage.faceid, "faceid"),
        (SystemImage.touchid, "touchid"),
        (SystemImage.network, "network"),
        (SystemImage.globe, "globe"),
        (SystemImage.share, "share"),
        (SystemImage.lock, "lock"),
        (SystemImage.none, "none"),
        (SystemImage.delete, "delete"),
        (SystemImage.checkmark, "checkmark"),
        (SystemImage.ellipsis, "ellipsis"),
        (SystemImage.info, "info"),
        (SystemImage.eyeglasses, "eyeglasses"),
        (SystemImage.lockOpen, "lockOpen"),
        (SystemImage.plus, "plus"),
        (SystemImage.eye, "eye")
        (SystemImage.searchNoResults, "no results")
    ]

    return ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
            ForEach(symbols, id: \.1) { symbol in
                SystemImageView(imageName: symbol.0, symbolName: symbol.1)
            }
        }
        .padding()
    }
}
