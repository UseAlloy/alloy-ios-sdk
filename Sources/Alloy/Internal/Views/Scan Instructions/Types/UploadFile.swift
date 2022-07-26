//
//  UploadFile.swift
//  
//
//  Created by Marc Hervera on 14/6/22.
//

import SwiftUI

internal struct UploadFile: View {
    
    // MARK: - Properties
    var documentType: DocumentType
    
    @EnvironmentObject private var configViewModel: ConfigViewModel
    @EnvironmentObject private var evaluationViewModel: EvaluationViewModel
    @StateObject private var documentViewModel = DocumentViewModel()
    
    @State private var showDocumentPicker = false
    @State private var selectedFileURL: URL?
    @State private var thumbnail: UIImage?
    @State private var evaluation: Evaluation?
    @State private var operationError: OperationError?
    
    // MARK: - Main
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.aGray, style: .init(lineWidth: 1, dash: [5], dashPhase: 2))
                    .background(
                        Color
                            .aGray
                            .opacity(thumbnail == nil ? 0.1 : 0.0)
                            .cornerRadius(8)
                            .padding(5)
                    )
                
                if let image = thumbnail {
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                        .padding(5)
                    
                }
                
                if documentViewModel.outcome == nil, thumbnail == nil {
                    
                    Button {
                        
                        showDocumentPicker = true
                        
                    } label: {
                        
                        Text("scan_instructions_upload", bundle: .module)
                            .textCase(.uppercase)
                        
                    }
                    .padding(.horizontal, 50)
                    .buttonStyle(DefaultButtonStyle())
                    .shadow(color: configViewModel.theme.button.opacity(0.27), radius: 24, x: 0, y: 12)
                    
                }
                
            }
            .aspectRatio(DocumentOverlayType.pdf.cameraOverlaRatio, contentMode: .fit)
            .modifier(TakenImageStatus.Loading(show: documentViewModel.isLoading))
            .modifier(TakenImageStatus.Accepted(show: documentViewModel.outcome == .approved || documentViewModel.outcome == .manualReview))
            .modifier(TakenImageStatus.Denied(show: documentViewModel.outcome == .denied))
            .modifier(TakenImageStatus.Retake(show: documentViewModel.outcome == .retakeImages, retake: {
                
                restart()
                
            }))
            .padding(.horizontal, DocumentOverlayType.pdf.cameraOverlayHorizontalPadding)
            .errorAlert(error: $operationError)
            
            Spacer()
            
            switch documentViewModel.outcome {
            case .approved, .manualReview, .pendingEvaluation:
                ScanFooter(documentType: documentType) { restart() }
                
            case .denied:
                DeniedFooter { restart() }
                
            default:
                EmptyView()
                
            }
            
        }
        .sheet(isPresented: $showDocumentPicker) {
            
            DocumentPicker(selectedFileURL: $selectedFileURL)
            
        }
        .onChange(of: selectedFileURL) { newValue in
            
            if let url = selectedFileURL {
                
                Task {
                    
                    thumbnail = try await newValue?.thumbnail
                    let data = try Data(contentsOf: url)
                    
                    do {
                        
                        // Create document
                        let payload = DocumentPayload(type: documentType)
                        var createUpload = try await documentViewModel
                            .create(
                                document: payload,
                                andUploadData: data
                            )
                        createUpload.step = .front
                        
                        if AlloySettings.configure.evaluateOnUpload {
                        
                            // Evaluate
                            try await documentViewModel
                                .evaluate(
                                    step: .front,
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
    
    private func restart() {
        
        thumbnail = nil
        documentViewModel.restart()
        evaluationViewModel.removeLast()
        
    }
    
}

struct UploadFile_Previews: PreviewProvider {
    static var previews: some View {
        UploadFile(documentType: .doc1065)
    }
}
