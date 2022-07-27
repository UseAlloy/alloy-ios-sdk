//
//  EvaluationViewModel.swift
//  
//
//  Created by Marc Hervera on 14/6/22.
//

import Foundation

internal enum ResultType {
    
    case success
    case pendingReview
    case denied
    case retakeImages
    case maxEvaluationAttempsExceded
    case error
    
}

@MainActor
class EvaluationViewModel: ObservableObject {
    
    // MARK: - Properties
    private var isLoading = false
    @Published var evaluatingProgress = 0.0
    
    let evaluationData: EvaluationData
    var resultType: ResultType {
        if evaluations.contains(where: { $0.evaluation.summary.outcome == .denied }) {
            return .denied
        } else if evaluations.contains(where: { $0.evaluation.summary.outcome == .manualReview }) {
            return .pendingReview
        } else if evaluations.allSatisfy({ $0.evaluation.summary.outcome == .approved }) {
            return .success
        } else if evaluations.allSatisfy({ $0.evaluation.summary.outcome == .retakeImages }) {
            return .retakeImages
        } else {
            return .error
        }
    }
    var anyPendingEvaluation: Bool {
        !documentUploads.isEmpty
    }
    var pendingOtherDocuments: Set<DocumentCreateUploadResponse> {
        documentUploads.filter { createUpload in
            DocumentType.documentTypes.contains(createUpload.type)
        }
    }
    
    private var documentUploads = Set<DocumentCreateUploadResponse>()
    private var evaluations = Set<Evaluation>()
    
    // MARK: - Init
    init(data: EvaluationData) {
        
        self.evaluationData = data
        
    }
    
    // MARK: - Custom
    func restart() {
        
        documentUploads.removeAll()
        evaluations.removeAll()
        
    }
    
    func removeLast() {
        
        if let last = evaluations.max() {
            evaluations.remove(last)
        }
        
    }
    
    func addEvaluation(from creation: DocumentCreateUploadResponse?, and evaluation: DocumentEvaluationResponse?) {
        
        if let creation = creation, let evaluation = evaluation {
            addEvaluation(evaluation: .init(creation: creation, evaluation: evaluation))
        }
        
    }
    
    func addEvaluation(evaluation: Evaluation) {
        
        evaluations.insert(evaluation)
        
    }
    
    func addPendingDocument(upload: DocumentCreateUploadResponse) {
        
        documentUploads.insert(upload)
        
    }
    
    func evaluatePendingIDDocuments() async throws {
        guard !isLoading else {
            return
        }
        isLoading = true
        defer { isLoading = false }
        
        evaluations.removeAll()
        
        // Get parts
        let frontID = documentUploads.first(where: {
            $0.step == .front && ($0.type == .license || $0.type == .canadaProvincialID || $0.type == .indigenousCard)
        })
        let backID = documentUploads.first(where: {
            $0.step == .back && ($0.type == .license || $0.type == .canadaProvincialID || $0.type == .indigenousCard)
        })
        let passport = documentUploads.first(where: {
            $0.step == .front && $0.type == .passport
        })
        let selfie = documentUploads.first(where: {
            $0.step == .selfie && $0.type == .selfie
        })
        
        evaluatingProgress = 0.0
        
        // ID type
        if let front = frontID, let back = backID, let selfie = selfie {
                        
            let evaluation = try await EvaluationEndpoint
                .evaluateFinal(
                    data: evaluationData,
                    front: front,
                    back: back,
                    selfie: selfie
                )
                .request(type: DocumentEvaluationResponse.self)
            
            let result = Evaluation(creation: front, evaluation: evaluation)
            addEvaluation(evaluation: result)
            
            documentUploads.remove(front)
            documentUploads.remove(back)
            documentUploads.remove(selfie)
                        
        }
        
        // Passport type
        if let passport = passport, let selfie = selfie {

            let evaluation = try await EvaluationEndpoint
                .evaluateFinal(
                    data: evaluationData,
                    front: passport,
                    selfie: selfie
                )
                .request(type: DocumentEvaluationResponse.self)
            
            let result = Evaluation(creation: passport, evaluation: evaluation)
            addEvaluation(evaluation: result)
                        
            documentUploads.remove(passport)
            documentUploads.remove(selfie)
            
        }
        
        // Other documents
        evaluatingProgress = 0.25
        let step = 0.75 / Double(pendingOtherDocuments.count)
        
        for document in pendingOtherDocuments {

            let evaluation = try await EvaluationEndpoint
                .evaluate(
                    step: .front,
                    data: evaluationData,
                    createUploadResponse: document
                )
                .request(type: DocumentEvaluationResponse.self)
            
            let result = Evaluation(creation: document, evaluation: evaluation)
            addEvaluation(evaluation: result)
            
            documentUploads.remove(document)
            
            evaluatingProgress += step
            
        }
        
        evaluatingProgress = 1.0
        
    }
    
}
