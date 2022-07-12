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
    case error
    
}

@MainActor
class EvaluationViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var isLoading = false
    @Published var evaluatingProgress = 0.0
    
    let evaluationData: EvaluationData
    var resultType: ResultType {
        if evaluations.contains(where: { $0.evaluation.summary.outcome == .denied }) {
            return .denied
        } else if evaluations.contains(where: { $0.evaluation.summary.outcome == .manualReview }) {
            return .pendingReview
        } else if evaluations.allSatisfy({ $0.evaluation.summary.outcome == .approved }) {
            return .success
        } else {
            return .error
        }
    }
    var anyPendingEvaluation: Bool {
        !documentUploads.isEmpty
    }
    
    private var documentUploads = [DocumentCreateUploadResponse]()
    private var evaluations = Set<Evaluation>()
    
    // MARK: - Init
    init(data: EvaluationData) {
        
        self.evaluationData = data
        
    }
    
    // MARK: - Custom
    func restart() {
        
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
        
        documentUploads.append(upload)
        
    }
    
    func evaluatePendingDocuments() async throws {
        
        // Get ID
        
    }
    
}
