//
//  TakeSelfieView.swift
//  
//
//  Created by Marc Hervera on 24/5/22.
//

import SwiftUI

struct TakeSelfieView: View {
    
    // MARK: - Properties
    @Environment(\.presentationMode) private var presentation
    @EnvironmentObject private var configViewModel: ConfigViewModel
    @EnvironmentObject private var evaluationViewModel: EvaluationViewModel
    @StateObject private var documentViewModel = DocumentViewModel()
    
    @State private var image: UIImage?
    @State private var showCamera = false
    @State private var operationError: OperationError?
    
    // MARK: - Main
    var body: some View {
        
        VStack(spacing: 30) {
            
            Text("take_selfie_subtitle", bundle: .module)
                .font(.subheadline)
                .foregroundColor(configViewModel.theme.title)
                .multilineTextAlignment(.center)
                .padding(.top, 30)
            
            VStack(spacing: 0) {
                
                ZStack {
                    
                    ZStack {
                        
                        Image(.selfie)
                            .resizable()
                            .aspectRatio(
                                DocumentOverlayType.selfie.cameraOverlaRatio,
                                contentMode: .fit
                            )

                        if let image = image {
                            
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(
                                    DocumentOverlayType.selfie.cameraOverlaRatio,
                                    contentMode: .fit
                                )
                                .cornerRadius(12)
                            
                        }
                        
                    }
                    
                    if documentViewModel.outcome == nil, image == nil {
                        
                        Button {
                            
                            showCamera = true
                            
                        } label: {
                            
                            Text("scan_instructions_take_picture", bundle: .module)
                                .textCase(.uppercase)
                            
                        }
                        .padding(.horizontal, 25)
                        .buttonStyle(DefaultButtonStyle())
                        .shadow(color: configViewModel.theme.button.opacity(0.27), radius: 24, x: 0, y: 12)
                        
                    }

                }
                .modifier(TakenImageStatus.Loading(show: documentViewModel.isLoading))
                .modifier(TakenImageStatus.Accepted(show: documentViewModel.outcome == .approved || documentViewModel.outcome == .manualReview))
                .modifier(TakenImageStatus.Denied(show: documentViewModel.outcome == .denied))
                .modifier(TakenImageStatus.Retake(show: documentViewModel.outcome == .retakeImages, retake: {
                    
                    restart()
                    
                }))
                .padding(.horizontal, 20)
                .errorAlert(error: $operationError)
                
                Spacer()
         
                switch documentViewModel.outcome {
                case .approved, .manualReview, .pendingEvaluation:
                    ScanFooter { restart() }
                    
                case .denied:
                    DeniedFooter { restart() }
                    
                default:
                    EmptyView()
                    
                }

            }
            .shadow(color: .aShadow.opacity(0.06), radius: 12, x: 0, y: 6)
            .sheet(isPresented: $showCamera) {
                
                ScanDocumentView(documentOverlayType: .selfie, image: $image)
                
            }
            .onChange(of: image) { newValue in
                
                if let data = newValue?.jpegData(compressionQuality: 0.9) {
                    
                    Task {
                        
                        do {
                            
                            // Create/upload document
                            let payload = DocumentPayload(type: .selfie)
                            let createUpload = try await documentViewModel
                                .create(
                                    document: payload,
                                    andUploadData: data
                                )
                            
                            if AlloySettings.configure.evaluateOnUpload {
                                
                                // Evaluate
                                try await documentViewModel
                                    .evaluate(
                                        step: .selfie,
                                        evaluationData: evaluationViewModel.evaluationData,
                                        createUploadResponse: createUpload
                                    )
                                
                                // Save evaluation
                                evaluationViewModel.addEvaluation(
                                    from: createUpload,
                                    and: documentViewModel.evaluation
                                )
                                
                            } else {
                                
                                // Next document (evaluation at finish)
                                evaluationViewModel.addPendingDocument(upload: createUpload)
                                documentViewModel.outcome = .pendingEvaluation
                                
                            }
                            
                        } catch {
                            
                            restart()
                            operationError = .unknown
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        .padding(.horizontal, 40)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            
            ToolbarItem(placement: .navigationBarLeading) {
                
                Button {
                    
                    presentation.wrappedValue.dismiss()
                    
                } label: {
                    
                    Image(.arrowBack)
                        .foregroundColor(.aBlack)
                    
                }

            }
            
            ToolbarItem(placement: .principal) {
                
                Text("take_selfie_title", bundle: .module)
                    .bold()
                    .foregroundColor(configViewModel.theme.title)
                
            }
            
        }
        
    }
    
    private func restart() {
        
        image = nil
        documentViewModel.restart()
        evaluationViewModel.removeLast()
        
    }
    
}

struct TakeSelfieView_Previews: PreviewProvider {
    static var previews: some View {
        TakeSelfieView()
    }
}
