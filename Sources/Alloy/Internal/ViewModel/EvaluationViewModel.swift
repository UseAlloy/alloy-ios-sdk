//
//  EvaluationViewModel.swift
//  
//
//  Created by Marc Hervera on 14/6/22.
//

import Foundation

class EvaluationViewModel: ObservableObject {
    
    // MARK: - Properties
    let evaluationData: EvaluationData
    var allApproved: Bool {
        return evaluations.allSatisfy({ $0.evaluation.summary.outcome == .approved })
    }
    
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
    
}
