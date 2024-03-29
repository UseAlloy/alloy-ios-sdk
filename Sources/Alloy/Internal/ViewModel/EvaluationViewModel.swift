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

enum EvaluationError: Error {
    case selfieNotFound
}

@MainActor
class EvaluationViewModel: ObservableObject {
    
    let evaluationData: EvaluationData

    // MARK: - Published
    @Published var evaluatingProgress = 0.0

    var resultType: ResultType {
        if error != nil {
            return .error
        } else if evaluations.contains(where: { $0.evaluation.summary.outcome == .denied }) {
            return .denied
        } else if evaluations.contains(where: { $0.evaluation.summary.outcome == .manualReview }) {
            return .pendingReview
        } else if evaluations.allSatisfy({ $0.evaluation.summary.outcome == .approved }) {
            return .success
        } else if evaluations.allSatisfy({ $0.evaluation.summary.outcome == .retakeImages }) {
            return evaluationAttemptIsAllowed() ? .retakeImages : .maxEvaluationAttempsExceded
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

    // MARK: - Private
    private var isLoading = false
    private var evaluationAttemps = 0
    private var documentUploads = Set<DocumentCreateUploadResponse>()
    private var evaluations = Set<Evaluation>()
    private var error: EvaluationError?

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

    func remove(_ uploads: [DocumentCreateUploadResponse?]) {

        uploads
            .compactMap { $0 }
            .forEach { documentUploads.remove($0) }
        
    }

    func evaluatePendingIDDocuments() async throws {
        guard !isLoading else {
            return
        }
        isLoading = true
        defer { isLoading = false }
        increaseEvaluationAttempts()

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
        
        evaluations.removeAll()
        evaluatingProgress = 0.0

        // ID type
        if let front = frontID, let back = backID, selfieExistIfNeeded(selfie: selfie) {

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

            remove([front,back,selfie])
        }
        
        // Passport type
        if let passport = passport, selfieExistIfNeeded(selfie: selfie) {

            let evaluation = try await EvaluationEndpoint
                .evaluateFinal(
                    data: evaluationData,
                    front: passport,
                    selfie: selfie
                )
                .request(type: DocumentEvaluationResponse.self)
            
            let result = Evaluation(creation: passport, evaluation: evaluation)
            addEvaluation(evaluation: result)

            remove([passport,selfie])
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

// MARK: - EvaluationAttempts
extension EvaluationViewModel {
    func increaseEvaluationAttempts() {
        evaluationAttemps += 1
    }

    func evaluationAttemptIsAllowed() -> Bool {
        evaluationAttemps < AlloySettings.configure.maxEvaluationAttempts
    }

    func resetEvaluationAttempts() {
        evaluationAttemps = 0
    }
}

// MARK: - Private
private extension EvaluationViewModel {
    func selfieExistIfNeeded(selfie: DocumentCreateUploadResponse?) -> Bool {
        if AlloySettings.configure.selfieEnabled,
           selfie == nil {
            error = .selfieNotFound
            evaluations.removeAll()
            documentUploads.removeAll()
            return false
        }
        return true
    }
}
