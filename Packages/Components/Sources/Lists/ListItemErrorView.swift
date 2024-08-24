// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct ListItemErrorView: View {
    private let listStyleColor = UIColor.dynamicColor(UIColor.systemBackground.color, dark: UIColor.secondarySystemBackground.color)

    let errorTitle: String?
    let errorSystemNameImage: String
    let error: Error
    let retryTitle: String?
    let retryAction: (() -> Void)?

    public init(
        errorTitle: String?,
        errorSystemNameImage: String,
        error: Error,
        retryTitle: String? = nil,
        retryAction: (() -> Void)? = nil
    ) {
        self.errorTitle = errorTitle
        self.errorSystemNameImage = errorSystemNameImage
        self.error = error
        self.retryTitle = retryTitle
        self.retryAction = retryAction
    }

    public init(
        errorTitle: String,
        error: Error,
        retryTitle: String? = nil,
        retryAction: (() -> Void)? = nil
    ) {
        self.init(errorTitle: errorTitle,
                  errorSystemNameImage: SystemImage.errorOccurred,
                  error: error,
                  retryTitle: retryTitle,
                  retryAction: retryAction)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack(spacing: Spacing.small) {
                Image(systemName: errorSystemNameImage)
                    .foregroundColor(Colors.red)
                    .frame(width: Sizing.list.image, height: Sizing.list.image)
                Text(errorTitle ?? error.localizedDescription)
                    .textStyle(.headline)
                Spacer()
            }
            if errorTitle != nil {
                Text(error.localizedDescription)
                    .textStyle(.subheadline)
            }
            if let retry = retryAction, let retryTitle = retryTitle {
                Button(retryTitle, action: retry)
                    .buttonStyle(.clearBlue)
            }
        }
        .padding()
        .background(listStyleColor)
        .cornerRadius(8)
        .frame(maxWidth: .infinity)
        .listRowInsets(EdgeInsets())
    }
}

// MARK: - Preview

#Preview {
    List {
        Section(header: Text("General Error")) {
            ListItemErrorView(
                errorTitle: "Error Loading Data",
                error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unexpected error occurred. Please try again."]),
                retryTitle: "Retry",
                retryAction: {}
            )
        }

        Section(header: Text("Network Error")) {
            ListItemErrorView(
                errorTitle: "Network Error",
                error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load data. Check your internet connection."]),
                retryTitle: "Retry",
                retryAction: {}
            )
        }

        Section(header: Text("Operation Error")) {
            ListItemErrorView(
                errorTitle: "Operation Error",
                error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to complete the operation. Please try again later."]),
                retryTitle: "Retry",
                retryAction: nil
            )
        }

        Section(header: Text("Missing Error Title")) {
            ListItemErrorView(
                errorTitle: nil,
                errorSystemNameImage: SystemImage.errorOccurred,
                error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "An error without a specific title."]),
                retryTitle: "Retry",
                retryAction: nil
            )
        }

        Section(header: Text("Missing Error Title & Different image")) {
            ListItemErrorView(
                errorTitle: nil,
                errorSystemNameImage: SystemImage.ellipsis,
                error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "An error without a specific title."]),
                retryTitle: "Retry",
                retryAction: {}
            )
        }
    }
    .listStyle(InsetGroupedListStyle())
    .background(Colors.grayBackground)
    .previewDisplayName("Error States")
}
