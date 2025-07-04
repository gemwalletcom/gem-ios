// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct ListItemErrorView: View {
    let errorTitle: String?
    let errorSystemNameImage: String
    let error: Error
    let infoAction: (() -> Void)?

    public init(
        errorTitle: String?,
        errorSystemNameImage: String = SystemImage.errorOccurred,
        error: Error,
        infoAction: (() -> Void)? = nil
    ) {
        self.errorTitle = errorTitle
        self.errorSystemNameImage = errorSystemNameImage
        self.error = error
        self.infoAction = infoAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .small) {
            HStack(spacing: .small) {
                Image(systemName: errorSystemNameImage)
                    .foregroundColor(Colors.red)
                    .frame(width: .list.image, height: .list.image)
                Text(errorTitle ?? error.localizedDescription)
                    .textStyle(.headline)
                Spacer()
            }
            HStack(alignment: .firstTextBaseline, spacing: .small) {
                if let infoAction {
                    InfoButton(
                        action: infoAction
                    )
                }
                if errorTitle != nil {
                    Text(error.localizedDescription)
                        .textStyle(.subheadline)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Error States") {
    List {
        Section(header: Text("General Error")) {
            ListItemErrorView(
                errorTitle: "Error Loading Data",
                error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unexpected error occurred. Please try again."]),
            )
        }

        Section(header: Text("Network Error")) {
            ListItemErrorView(
                errorTitle: "Network Error",
                error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load data. Check your internet connection."]),
            )

            ListItemErrorView(
                errorTitle: "Insufficient funds",
                error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load data. Check your internet connection."]),
                infoAction: {}
            )
        }

        Section(header: Text("Operation Error")) {
            ListItemErrorView(
                errorTitle: "Operation Error",
                error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to complete the operation. Please try again later."]),
            )
        }

        Section(header: Text("Missing Error Title")) {
            ListItemErrorView(
                errorTitle: nil,
                errorSystemNameImage: SystemImage.errorOccurred,
                error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "An error without a specific title."]),
            )
        }

        Section(header: Text("Missing Error Title & Different image")) {
            ListItemErrorView(
                errorTitle: nil,
                errorSystemNameImage: SystemImage.ellipsis,
                error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "An error without a specific title."]),
            )
        }
    }
    .listStyle(InsetGroupedListStyle())
    .background(Colors.grayBackground)
}
