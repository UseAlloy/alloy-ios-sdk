//
//  EvaluationEndpoint.swift
//  
//
//  Created by Marc Hervera on 26/5/22.
//

import Foundation

internal enum EvaluationEndpoint {

    case evaluate(step: Evaluation.Variant, data: EvaluationData, createUploadResponse: DocumentCreateUploadResponse)
    case evaluateFinal(data: EvaluationData, front: DocumentCreateUploadResponse, back: DocumentCreateUploadResponse? = nil, selfie: DocumentCreateUploadResponse)
    
}

extension EvaluationEndpoint: Endpoint {
    
    var baseURLString: String {
        
        URLs.api
        
    }
    
    var path: String {
        
        "/evaluations"
        
    }
    
    var queryItems: [URLQueryItem]? {
        
        [
            .init(name: "production", value: "\(AlloySettings.configure.realProduction)")
        ]
        
    }
    
    var method: HTTPMethod {
        
        .post
        
    }
    
    var headers: HTTPHeaders? {
        
        var headers = HTTPHeaders()
        headers.add(name: "Alloy-Entity-Token", value: AlloySettings.configure.entityToken)
        headers.add(name: "Alloy-External-Entity-ID", value: AlloySettings.configure.externalEntityId)
        headers.add(.authorization(bearerToken: AlloySettings.configure.accessToken))
        return headers
        
    }
    
    var parameters: [String : Any]? {
        
        var customerData: [String: Any]?
        
        switch self {
        case .evaluate(let step, let data, let createUploadResponse):
            customerData = data.json
            customerData?["document_step"] = step.rawValue
            customerData?["document_type"] = createUploadResponse.type.rawValue
            customerData?["journey_application_token"] = AlloySettings.configure.journeyApplicationToken
            customerData?["journey_token"] = AlloySettings.configure.journeyToken
            
            switch step {
            case .front:
                customerData?["document_token_front"] = createUploadResponse.documentToken
                
            case .back:
                customerData?["document_token_back"] = createUploadResponse.documentToken
                
            case .selfie:
                customerData?["document_token_selfie"] = createUploadResponse.documentToken
                
            case .final:
                break
                
            }
            
        case .evaluateFinal(let data, let front, let back, let selfie):
            customerData = data.json
            customerData?["document_step"] = Evaluation.Variant.final.rawValue
            customerData?["document_type"] = front.type.rawValue
            customerData?["journey_application_token"] = AlloySettings.configure.journeyApplicationToken
            customerData?["journey_token"] = AlloySettings.configure.journeyToken
            
            customerData?["document_token_front"] = front.documentToken
            customerData?["document_token_back"] = back?.documentToken
            customerData?["document_token_selfie"] = selfie.documentToken
            
        }
        
        return customerData
        
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

