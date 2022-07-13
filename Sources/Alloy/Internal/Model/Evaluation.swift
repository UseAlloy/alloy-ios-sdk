//
//  Evaluation.swift
//  
//
//  Created by Marc Hervera on 14/6/22.
//

import Foundation


internal struct Evaluation: Identifiable {
    
    internal let id = UUID()
    private let createdAt = Date()
    var variant: Variant {
        get {
            evaluation.summary.customFields.variant
        }
    }
    let creation: DocumentCreateUploadResponse
    let evaluation: DocumentEvaluationResponse
    
    enum Variant: String, Codable {
        case front
        case back
        case selfie
        case final
    }
    
}

extension Evaluation: Equatable, Hashable, Comparable {

    static func == (lhs: Evaluation, rhs: Evaluation) -> Bool {
        
        lhs.id == rhs.id
        
    }

    func hash(into hasher: inout Hasher) {
        
        hasher.combine(id)
        hasher.combine(createdAt)
        
    }
    
    static func < (lhs: Evaluation, rhs: Evaluation) -> Bool {
        
        lhs.createdAt < rhs.createdAt
        
    }

}

