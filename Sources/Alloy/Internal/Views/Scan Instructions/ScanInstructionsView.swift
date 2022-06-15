//
//  ScanInstructionsView.swift
//
//
//  Created by Marc Hervera on 12/5/22.
//

import SwiftUI

private typealias CreateResponses = (front: DocumentCreateUploadResponse?, back: DocumentCreateUploadResponse?)

internal struct ScanInstructionsView: View {
    
    // MARK: - Properties
    var documentType: DocumentType
    @EnvironmentObject private var configViewModel: ConfigViewModel
    @EnvironmentObject private var evaluationViewModel: EvaluationViewModel
    @Environment(\.presentationMode) private var presentation

    // MARK: - Main
    var body: some View {
        
        VStack(spacing: 30) {
            
            subtitle(type: documentType)
                .font(.subheadline)
                .foregroundColor(configViewModel.theme.title)
                .multilineTextAlignment(.center)
                .padding(.top, 30)
            
            Group {
                
                switch documentType {
                case .passport:
                    PassportTakePicture(documentType: documentType)
                    
                case .license, .canadaProvincialID, .indigenousCard:
                    FrontBackTakePicture(documentType: documentType)
                    
                default:
                    UploadFile(documentType: documentType)
                
                }
                
            }
            .adjustBottomPadding()
            
        }
        .padding(.horizontal, 40)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            
            ToolbarItem(placement: .navigationBarLeading) {
                
                Button {
                    
                    evaluationViewModel.removeLast()
                    presentation.wrappedValue.dismiss()
                    
                } label: {
                    
                    Image(.arrowBack)
                        .foregroundColor(.aBlack)
                    
                }

            }
            
            ToolbarItem(placement: .principal) {
                
                title(type: documentType)
                    .bold()
                    .foregroundColor(configViewModel.theme.title)
                
            }
            
        }
        
    }
    
    func title(type: DocumentType) -> Text {
        
        var title = ""
        switch documentType {
        case .passport:
            title = "scan_instructions_passport_title"
            
        case .license:
            title = "scan_instructions_license_title"
            
        case .canadaProvincialID:
            title = "scan_instructions_canadaProvincialID_title"
            
        case .indigenousCard:
            title = "scan_instructions_indigenousCard_title"
            
        default:
            title = "scan_instructions_bank_statement_title"
            
        }
        
        return Text(LocalizedStringKey(title), bundle: .module)
        
    }
    
    func subtitle(type: DocumentType) -> Text {
        
        var title = ""
        switch documentType {
        case .passport:
            title = "scan_instructions_passport_subtitle"
            
        case .license, .canadaProvincialID, .indigenousCard:
            title = "scan_instructions_front_back_subtitle"
            
        default:
            title = "scan_instructions_bank_statement_subtitle"
            
        }
        
        return Text(LocalizedStringKey(title), bundle: .module)
        
    }
    
}

internal struct ScanFooter: View {
    
    // MARK: - Properties
    var retry: () -> Void

    @EnvironmentObject private var configViewModel: ConfigViewModel
    @State private var showNext = false
    
    // MARK: - Main
    var body: some View {
        
        VStack(spacing: 20) {
            
            Button {
                
                configViewModel.markCurrentStepCompleted()
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

struct ScanInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        ScanInstructionsView(documentType: .license)
    }
}
