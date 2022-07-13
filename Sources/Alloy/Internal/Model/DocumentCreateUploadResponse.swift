//
//  DocumentCreateResponse.swift
//  
//
//  Created by Marc Hervera on 31/5/22.
//

import Foundation

internal struct DocumentCreateUploadResponse: Codable {
    
    var step: Evaluation.Variant?
    let documentToken: String
    let type: DocumentType
    let name: String
    let `extension`: DocumentExtension
    let uploaded: Bool
    let timestamp: Date
    
}

extension DocumentCreateUploadResponse: Equatable, Hashable {

    static func == (lhs: DocumentCreateUploadResponse, rhs: DocumentCreateUploadResponse) -> Bool {
        
        lhs.documentToken == rhs.documentToken
        
    }

    func hash(into hasher: inout Hasher) {
        
        hasher.combine(documentToken)
        hasher.combine(timestamp)
        
    }

}

