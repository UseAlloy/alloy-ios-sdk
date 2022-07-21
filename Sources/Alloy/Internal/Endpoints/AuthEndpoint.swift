//
//  AuthEndpoint.swift
//  
//
//  Created by Marc Hervera on 24/5/22.
//

import Foundation

internal enum AuthEndpoint {
    
    case initialization(id: String)
    
}

extension AuthEndpoint: Endpoint {
    
    var baseURLString: String {
        
        URLs.api
        
    }
    
    var path: String {
        
        "/auth/init"
        
    }
    
    var queryItems: [URLQueryItem]? {
        
        [
            .init(name: "production", value: "\(AlloySettings.configure.production)")
        ]
        
    }
    
    var method: HTTPMethod {
        
        .post
        
    }
    
    var headers: HTTPHeaders? {
        
        var headers = HTTPHeaders()
        headers.add(name: "Alloy-Entity-Token", value: AlloySettings.configure.entityToken)
        headers.add(name: "Alloy-External-Entity-ID", value: AlloySettings.configure.externalEntityId)
        return headers
        
    }
    
    var parameters: [String : Any]? {
        
        switch self {
        case .initialization(let id):
            return ["id": id]
        }
        
    }
    
    var body: Data? {
        
        nil
        
    }
    
    var parameterEncoding: ParameterEncoding {
        
        .JSONEncoding
        
    }
    
    var showDebugInfo: Bool {
        
#if DEBUG
        return true
#else
        return false
#endif
        
    }
    
}
