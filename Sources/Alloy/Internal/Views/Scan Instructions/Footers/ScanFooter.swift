import SwiftUI

internal struct ScanFooter: View {

    // MARK: - Properties
    var documentType: DocumentType?
    var retry: () -> Void

    @EnvironmentObject private var configViewModel: ConfigViewModel
    @State private var showNext: Bool = false

    // MARK: - Main
    var body: some View {

        VStack(spacing: 20) {

            Button {

                configViewModel.markCurrentStepCompleted(documentSelected: documentType)
                showNext = true

            } label: {

                Text("scan_instructions_next", bundle: .module)

            }
            .buttonStyle(DefaultButtonStyle())

            Button {

                retry()

            } label: {

                Text("scan_instructions_retry", bundle: .module)
                    .font(.subheadline)
                    .foregroundColor(configViewModel.theme.button)

            }


            NavigationLink(isActive: $showNext) {

                configViewModel.nextStepView

            } label: {
                EmptyView()
            }
            .hidden()

        }
        .frame(maxWidth: .infinity, alignment: .center)

    }

}
