//
//  DocumentCreateResponse.swift
//  
//
//  Created by Marc Hervera on 31/5/22.
//

import Foundation

internal struct DocumentCreateUploadResponse: Codable {
    
    let documentToken: String
    let type: DocumentType
    let name: String
    let `extension`: DocumentExtension
    let uploaded: Bool
    let timestamp: Date
    
}
