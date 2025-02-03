// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct CleanListRowModifier: ViewModifier {
    private let listRowBackground: Color
    private let listRowInsets: EdgeInsets

    public init(
        listRowBackground: Color,
        listRowInsets: EdgeInsets
    ) {
        self.listRowBackground = listRowBackground
        self.listRowInsets = listRowInsets
    }

    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .textCase(nil)
            .listRowBackground(listRowBackground)
            .listRowSeparator(.hidden)
            .listRowInsets(listRowInsets)
    }
}

public extension View {
    func cleanListRow(
        listRowBackground: Color = .clear,
        listRowInsets: EdgeInsets = .zero
    ) -> some View {
        modifier(
            CleanListRowModifier(
                listRowBackground: listRowBackground,
                listRowInsets: listRowInsets
            )
        )
    }

    func cleanListRow(
        listRowBackground: Color = .clear,
        topOffset: CGFloat
    ) -> some View {
        cleanListRow(
            listRowBackground: listRowBackground,
            listRowInsets: EdgeInsets(
                top: topOffset,
                leading: .zero,
                bottom: .zero,
                trailing: .zero
            )
        )
    }
}
