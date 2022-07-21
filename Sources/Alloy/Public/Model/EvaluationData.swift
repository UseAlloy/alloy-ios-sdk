//
//  EvaluationData.swift
//  
//
//  Created by Marc Hervera on 24/5/22.
//

import Foundation

public struct EvaluationData: Codable {

    let nameFirst: String
    let nameLast: String
    var addressLine1: String?
    var addressLine2: String?
    var addressCity: String?
    var addressState: String?
    var addressPostalCode: String?
    var addressCountryCode: String?
    var birthDate: String?
    
    public init(nameFirst: String, nameLast: String, addressLine1: String? = nil, addressLine2: String? = nil, addressCity: String? = nil, addressState: String? = nil, addressPostalCode: String? = nil, addressCountryCode: String? = nil, birthDate: String? = nil) {
        
        self.nameFirst = nameFirst
        self.nameLast = nameLast
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressCity = addressCity
        self.addressState = addressState
        self.addressPostalCode = addressPostalCode
        self.addressCountryCode = addressCountryCode
        self.birthDate = birthDate
        
    }

}
