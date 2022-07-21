//
//  DocumentEndpoint.swift
//  
//
//  Created by Marc Hervera on 31/5/22.
//

import Foundation
import SwiftUI

internal enum DocumentEndpoint {
    
    case create(payload: DocumentPayload)
    case upload(image: Data, boundaryID: String, createUploadResponse: DocumentCreateUploadResponse)
    
}

extension DocumentEndpoint: Endpoint {

    var baseURLString: String {
        
        URLs.api
        
    }
    
    var path: String {
        
        switch self {
        case .create:
            var path = "/documents"
            if let token = AlloySettings.configure.entityToken {
                path = "/entities/\(token)\(path)"
            }
            return path
            
        case .upload(_, _, let createUploadResponse):
            var path = "/documents/\(createUploadResponse.documentToken)"
            if let token = AlloySettings.configure.entityToken {
                path = "/entities/\(token)\(path)"
            }
            return path
            
        }
        
    }
    
    var queryItems: [URLQueryItem]? {
        
        switch self {
        case .create:
            return [
                .init(name: "production", value: "\(AlloySettings.configure.production)")
            ]
            
        case .upload(_, _, let createUploadResponse):
            return [
                .init(name: "production", value: "\(AlloySettings.configure.production)"),
                .init(name: "documentType", value: createUploadResponse.type.rawValue)
            ]
            
        }
        
    }
    
    var method: HTTPMethod {
        
        .post
        
    }
    
    var headers: HTTPHeaders? {
        
        var headers = HTTPHeaders()
        headers.add(name: "Alloy-Entity-Token", value: AlloySettings.configure.entityToken)
        headers.add(name: "Alloy-External-Entity-ID", value: AlloySettings.configure.externalEntityId)
        headers.add(.authorization(bearerToken: AlloySettings.configure.accessToken))
        
        switch self {
        case .upload(_, let boundaryID, _):
            headers.add(.contentType("multipart/form-data; boundary=\("Boundary-\(boundaryID)")"))
            
        default:
            break
                                        
        }
        
        return headers
        
    }
    
    var parameters: [String : Any]? {
        
        switch self {
        case .create(let payload):
            return payload.json
            
        case .upload:
            return nil
            
        }
        
    }
    
    var body: Data? {
        
        switch self {
        case .upload(let data, let boundaryID, let createUploadResponse):
            return data.convertMultipart(
                boundary: "Boundary-\(boundaryID)",
                filename: "blob",
                mimeType: createUploadResponse.extension.mimeType
            )
            
        default:
            return nil
            
        }
        
    }
    
    var parameterEncoding: ParameterEncoding {
        
        switch self {
        case .create:
            return .JSONEncoding
            
        case .upload:
            return .noEncoding
            
        }
        
    }
    
    var showDebugInfo: Bool {
        
#if DEBUG
        return true
#else
        return false
#endif
        
    }
    
}


