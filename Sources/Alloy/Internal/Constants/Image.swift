//
//  Image.swift
//  
//
//  Created by Marc Hervera on 9/5/22.
//

import SwiftUI

internal extension Image {
    
    enum Identifier {
        
        // Icons/others
        case checkDocuments
        case daylightBest
        case mindSurroundings
        case preparedSelfie
        case passport
        case license
        case form
        case frontID
        case backID
        case passportBackground
        case selfie
        case logo
        
        // Animations
        case resultSuccess
        case resultFailure

    }
    
    enum Symbol: String {
        
        case xMark = "xmark"
        case arrowBack = "arrow.backward"
        case boltSlashFill = "bolt.slash.fill"
        case boltFill = "bolt.fill"
        case checkmark = "checkmark"
        case exclamationmarkCircle = "exclamationmark.circle"
        
    }

}

extension Image {
    
    init(_ identifier: Image.Identifier) {
        self.init("\(identifier)", bundle: .module)
    }
    
    init(_ symbol: Image.Symbol) {
        self.init(systemName: symbol.rawValue)
    }
    
}
