import SwiftUI

internal struct DeniedFooter: View {

    // MARK: - Properties
    var retry: () -> Void

    @EnvironmentObject private var configViewModel: ConfigViewModel

    // MARK: - Main
    var body: some View {

        VStack(spacing: 30) {

            VStack(spacing: 10) {

                Text("scan_instructions_denied", bundle: .module)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(configViewModel.theme.title)

                Text("scan_instructions_cannot_validated", bundle: .module)
                    .font(.subheadline)
                    .foregroundColor(configViewModel.theme.subtitle)
                    .multilineTextAlignment(.center)

            }

            VStack(spacing: 20) {

                Button {

                    retry()

                } label: {

                    Text("scan_instructions_retry", bundle: .module)

                }
                .buttonStyle(DefaultButtonStyle())

                Button {

                    dismiss()

                } label: {

                    Text("scan_instructions_leave", bundle: .module)
                        .font(.subheadline)
                        .foregroundColor(configViewModel.theme.button)

                }

            }

        }
        .frame(maxWidth: .infinity, alignment: .center)

    }

}
