//
//  FrontBackTakePicture.swift
//  
//
//  Created by Marc Hervera on 14/6/22.
//

import SwiftUI

internal struct FrontBackTakePicture: View {
    
    // MARK: - Properties
    var documentType: DocumentType
    
    @EnvironmentObject private var configViewModel: ConfigViewModel
    @EnvironmentObject private var evaluationViewModel: EvaluationViewModel
    @StateObject private var frontViewModel = DocumentViewModel()
    @StateObject private var backViewModel = DocumentViewModel()
    
    @State private var frontImage: UIImage?
    @State private var showFront = false
    @State private var backImage: UIImage?
    @State private var showBack = false
    @State private var operationError: OperationError?
    
    // MARK: - Main
    var body: some View {
        
        VStack(spacing: 15) {
            
            ZStack {
                
                ZStack {
                    
                    Image(.frontID)
                        .resizable()
                        .aspectRatio(
                            DocumentOverlayType.card(.front).cameraOverlaRatio,
                            contentMode: .fit
                        )
                    
                    if let image = frontImage {
                        
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(
                                DocumentOverlayType.card(.front).cameraOverlaRatio,
                                contentMode: .fit
                            )
                            .cornerRadius(12)
                        
                    }
                    
                }
                
                if frontViewModel.outcome == nil, frontImage == nil {
                    
                    Button {
                        
                        showFront = true
                        
                    } label: {
                        
                        Text("scan_instructions_take_front", bundle: .module)
                            .textCase(.uppercase)
                        
                    }
                    .padding(.horizontal, 50)
                    .buttonStyle(DefaultButtonStyle())
                    .shadow(color: configViewModel.theme.button.opacity(0.27), radius: 24, x: 0, y: 12)
                    .sheet(isPresented: $showFront) {
                        
                        ScanDocumentView(documentOverlayType: .card(.front), image: $frontImage)
                        
                    }
                    
                }
                
            }
            .cornerRadius(12)
            .shadow(color: .aShadow.opacity(0.06), radius: 12, x: 0, y: 6)
            .modifier(TakenImageStatus.Loading(show: frontViewModel.isLoading))
            .modifier(TakenImageStatus.Accepted(show: frontViewModel.outcome == .approved || frontViewModel.outcome == .manualReview))
            .modifier(TakenImageStatus.Denied(show: frontViewModel.outcome == .denied))
            .modifier(TakenImageStatus.Retake(show: frontViewModel.outcome == .retakeImages, retake: {
                
                restart(variant: .front)
                
            }))
            .padding(.horizontal, 20)
            .errorAlert(error: $operationError)
            
            ZStack {

                ZStack {
                    
                    Image(.backID)
                        .resizable()
                        .aspectRatio(
                            DocumentOverlayType.card(.back).cameraOverlaRatio,
                            contentMode: .fit
                        )
                    
                    if let image = backImage {
                        
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(
                                DocumentOverlayType.card(.back).cameraOverlaRatio,
                                contentMode: .fit
                            )
                            .cornerRadius(12)
                        
                    }
                    
                }
                
                if backViewModel.outcome == nil, backImage == nil {
                    
                    Button {
                        
                        showBack = true
                        
                    } label: {
                        
                        Text("scan_instructions_take_back", bundle: .module)
                            .textCase(.uppercase)
                        
                    }
                    .padding(.horizontal, 50)
                    .buttonStyle(DefaultButtonStyle())
                    .shadow(color: configViewModel.theme.button.opacity(0.27), radius: 24, x: 0, y: 12)
                    .sheet(isPresented: $showBack) {
                        
                        ScanDocumentView(documentOverlayType: .card(.back), image: $backImage)
                        
                    }
                    .disabled(frontViewModel.outcome == nil || frontViewModel.outcome == .denied)
                    .opacity(frontViewModel.outcome == nil || frontViewModel.outcome == .denied ? 0.6 : 1.0)
                    
                }
                
            }
            .cornerRadius(12)
            .shadow(color: .aShadow.opacity(0.06), radius: 12, x: 0, y: 6)
            .modifier(TakenImageStatus.Loading(show: backViewModel.isLoading))
            .modifier(TakenImageStatus.Accepted(show: backViewModel.outcome == .approved || backViewModel.outcome == .manualReview))
            .modifier(TakenImageStatus.Denied(show: backViewModel.outcome == .denied))
            .modifier(TakenImageStatus.Retake(show: backViewModel.outcome == .retakeImages, retake: {
                
                restart(variant: .back)
                
            }))
            .padding(.horizontal, 20)
            
            Spacer()

            let outcomes = [frontViewModel.outcome, backViewModel.outcome]
            switch outcomes {
            case let outcome where outcome.allSatisfy({ $0 == .approved || $0 == .manualReview || $0 == .pendingEvaluation }):
                ScanFooter(documentType: documentType) { restart(variant: nil) }
                
            case let outcome where outcome.contains(where: { $0 == .denied }):
                DeniedFooter { restart(variant: nil) }
                
            default:
                EmptyView()
                
            }
            
        }
        .onChange(of: frontImage) { newValue in
            
            Task {
                
                do {
                    
                    try await createUploadEvaluate(image: newValue, variant: .front)
                    
                } catch {
                    
                    restart(variant: .front)
                    operationError = .unknown
                    
                }
                
            }

        }
        .onChange(of: backImage) { newValue in
            
            Task {
                
                do {
                    
                    try await createUploadEvaluate(image: newValue, variant: .back)
                    
                } catch {
                    
                    restart(variant: .back)
                    operationError = .unknown
                    
                }
                
            }

        }
        
    }
    
    private func createUploadEvaluate(image: UIImage?, variant: Evaluation.Variant) async throws {
        
        let documentViewModel = variant == .front ? frontViewModel : backViewModel
        
        if let data = image?.jpegData(compressionQuality: 0.9) {
            
            // Create/upload document
            let payload = DocumentPayload(type: documentType)
            var createUpload = try await documentViewModel
                .create(
                    document: payload,
                    andUploadData: data
                )
            createUpload.step = variant
            
            if AlloySettings.configure.evaluateOnUpload {
                
                // Evaluate
                try await documentViewModel
                    .evaluate(
                        step: variant,
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
            
        }
        
    }
    
    private func restart(variant: Evaluation.Variant?) {
        
        switch variant {
        case .front:
            frontImage = nil
            frontViewModel.restart()
            
        case .back:
            backImage = nil
            backViewModel.restart()
            
        default:
            frontImage = nil
            frontViewModel.restart()
            backImage = nil
            backViewModel.restart()
            evaluationViewModel.removeLast()
            evaluationViewModel.removeLast()
            
        }

    }
    
}

struct FrontBackTakePicture_Previews: PreviewProvider {
    static var previews: some View {
        FrontBackTakePicture(documentType: .canadaProvincialID)
    }
}
