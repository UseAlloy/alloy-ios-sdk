//
//  URLs.swift
//  
//
//  Created by Marc Hervera on 24/5/22.
//

import Foundation

internal struct URLs {
    
    static var api: String {
        if AlloySettings.configure.production {
            return "https://docv.alloy.co"
        }
        return "https://docv-dev-api.alloy.co/"
    }
    
}
