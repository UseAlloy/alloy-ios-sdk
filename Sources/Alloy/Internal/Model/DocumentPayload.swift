//
//  DocumentPayload.swift
//  
//
//  Created by Marc Hervera on 31/5/22.
//

import Foundation

internal struct DocumentPayload: Codable {
    
    let name: String
    let `extension`: DocumentExtension
    let type: DocumentType
    var note: String? = nil
    var noteAuthorAgentEmail: String? = nil
    
    // MARK: - Init
    init(type: DocumentType, note: String? = nil, noteAuthorAgentEmail: String? = nil) {
        
        self.name = type.rawValue
        switch type {
        case .passport, .license, .canadaProvincialID, .indigenousCard, .selfie:
            self.`extension` = .jpeg
        
        default:
            self.`extension` = .pdf
            
        }
        self.type = type
        self.note = note
        self.noteAuthorAgentEmail = noteAuthorAgentEmail
        
    }
    
}
