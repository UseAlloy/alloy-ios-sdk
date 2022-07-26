//
//  File.swift
//  
//
//  Created by Marc Hervera on 9/5/22.
//

import SwiftUI

public enum DocumentType: String, CaseIterable, Codable {
    
    case none
    case selfie = "utility"
    case passport
    case license
    case canadaProvincialID = "canada_provincial_id"
    case indigenousCard = "indigenous_card"
    case paystub
    case bankStatement = "bank_statement"
    case docW2 = "w2"
    case doc1099 = "1099"
    case doc1120 = "1120"
    case doc1065 = "1065"
    case docT1 = "t1"
    case docT4 = "t4"
    
}

internal extension DocumentType {
    var isKYC: Bool {
        switch self {
        case .license, .passport, .canadaProvincialID, .indigenousCard:
            return true
        default:
            return false
        }
    }
}

internal extension DocumentType {

    var icon: Image {
        
        switch self {
        case .passport:
            return Image(.passport)
            
        case .license, .canadaProvincialID, .indigenousCard:
            return Image(.license)
            
        default:
            return Image(.form)
        }
        
    }
    
    static var idTypes: [DocumentType] {
        
        [.selfie, .passport, .license, .canadaProvincialID, .indigenousCard]
        
    }
    
    static var documentTypes: [DocumentType] {
        
        Array(Set(DocumentType.allCases).symmetricDifference(Set(idTypes)))
        
    }
    
}
