//
//  DocumentEvaluationResponse.swift
//  
//
//  Created by Marc Hervera on 8/6/22.
//

import Foundation

internal struct DocumentEvaluationResponse: Codable {
    
    let timestamp: Date
    let evaluationToken: String
    let entityToken: String
    let summary: EvaluationSummary
    
    struct EvaluationSummary: Codable {
        
        enum Outcome: String, Codable {
            case approved = "Approved"
            case denied = "Denied"
            case manualReview = "Manual Review"
            case retakeImages = "Retake Images"
        }
        
        let outcome: Outcome
        let outcomeReasons: [String]
        let customFields: SummaryCustomFields
        
        struct SummaryCustomFields: Codable {
            
            let documentTokenFront: String?
            let documentTokenBack: String?
            let documentTokenSelfie: String?
            
            var variant: Evaluation.Variant {
                if documentTokenFront != nil { return .front }
                else if documentTokenBack != nil { return .back }
                else { return .selfie }
            }

        }
        
    }
    
}
