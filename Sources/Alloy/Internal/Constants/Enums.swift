//
//  Enums.swift
//  
//
//  Created by Marc Hervera on 15/6/22.
//

import Foundation

internal enum OperationError: LocalizedError {
    
    case unknown
    
}

extension OperationError {
    
    var errorDescription: String? {
        
        switch self {
        case .unknown:
            return NSLocalizedString("error_unknown", bundle: .module, comment: "")
            
        }
        
    }
    
}
