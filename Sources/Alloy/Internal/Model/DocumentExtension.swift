//
//  DocumentExtension.swift
//  
//
//  Created by Marc Hervera on 31/5/22.
//

import Foundation

internal enum DocumentExtension: String, Codable {
    
    case jpeg
    case png
    case pdf
    
}

internal extension DocumentExtension {
    
    var mimeType: String {
        switch self {
        case .jpeg, .png:
            return "image/\(rawValue)"
            
        case .pdf:
            return "application/pdf"
            
        }
    }
    
}
