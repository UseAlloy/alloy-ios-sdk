//
//  ScanInstructionsView.swift
//
//
//  Created by Marc Hervera on 12/5/22.
//

import SwiftUI

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
                    configViewModel.lastAttemptSelectedDocument = nil

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

struct ScanInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        
        AlloySettings.configure.apiKey = "028d85e0-aa24-4ca1-99f2-90e3ee3f4e6b"
        AlloySettings.configure.production = false
        AlloySettings.configure.evaluateOnUpload = false
        
        return ScanInstructionsView(documentType: .license)
            .environmentObject(ConfigViewModel())
            .environmentObject(EvaluationViewModel(data: .init(nameFirst: "", nameLast: "")))
    }
}
