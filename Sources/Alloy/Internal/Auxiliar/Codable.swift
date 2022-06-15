//
//  Codable.swift
//  
//
//  Created by Marc Hervera on 31/5/22.
//

import Foundation

extension Encodable {
    
    var data: Data? {
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return try? encoder.encode(self)
        
    }
    
    var json: [String: Any]? {
        
        guard let data = self.data else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
    }
    
}
