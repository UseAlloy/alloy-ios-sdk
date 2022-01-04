import Foundation

public typealias AlloyEvaluationToken = String

// Create Entity

public struct AlloyEvaluationData: Codable {
    let nameFirst: String
    let nameLast: String
    public var addressLine1: String?
    public var addressLine2: String?
    public var addressCity: String?
    public var addressState: String?
    public var addressPostalCode: String?
    public var addressCountryCode: String?
    public var birthDate: String?

    public init(
        nameFirst: String,
        nameLast: String,
        addressLine1: String? = nil,
        addressLine2: String? = nil,
        addressCity: String? = nil,
        addressState: String? = nil,
        addressPostalCode: String? = nil,
        addressCountryCode: String? = nil,
        birthDate: String? = nil
    ) {
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

    enum CodingKeys: String, CodingKey {
        case nameFirst = "name_first",
             nameLast = "name_last",
             addressLine1 = "address_line_1",
             addressLine2 = "address_line_2",
             addressCity = "address_city",
             addressState = "address_state",
             addressPostalCode = "address_postal_code",
             addressCountryCode = "address_country_code",
             birthDate = "birth_date"
    }
}

internal struct AlloyEvaluationResponse: Decodable {
    let token: AlloyEvaluationToken
    let entityToken: AlloyEntityToken

    private enum CodingKeys: String, CodingKey {
        case token = "evaluation_token",
             entityToken = "entity_token"
    }
}

// Evaluate document

internal struct AlloyCardEvaluationData: Encodable {
    let evaluationData: AlloyEvaluationData
    let evaluationStep: AlloyCardEvaluationStep

    private enum CodingKeys: String, CodingKey {
        case document_step,
             document_token_front,
             document_token_back
    }

    func encode(to encoder: Encoder) throws {
        var cardContainer = encoder.container(keyedBy: CodingKeys.self)
        var evaluationContainer = encoder.container(keyedBy: AlloyEvaluationData.CodingKeys.self)

        try evaluationContainer.encode(evaluationData.nameFirst, forKey: .nameFirst)
        try evaluationContainer.encode(evaluationData.nameLast, forKey: .nameLast)
        try evaluationContainer.encode(evaluationData.addressCity, forKey: .addressCity)
        try evaluationContainer.encode(evaluationData.addressCountryCode, forKey: .addressCountryCode)
        try evaluationContainer.encode(evaluationData.addressLine1, forKey: .addressLine1)
        try evaluationContainer.encode(evaluationData.addressLine2, forKey: .addressLine2)
        try evaluationContainer.encode(evaluationData.addressPostalCode, forKey: .addressPostalCode)
        try evaluationContainer.encode(evaluationData.addressState, forKey: .addressState)
        try evaluationContainer.encode(evaluationData.birthDate, forKey: .birthDate)

        switch evaluationStep {
        case let .front(token):
            try cardContainer.encode("front", forKey: .document_step)
            try cardContainer.encode(token, forKey: .document_token_front)
        case let .back(token):
            try cardContainer.encode("back", forKey: .document_step)
            try cardContainer.encode(token, forKey: .document_token_back)
        case let .finalID(tokenFront, tokenBack):
            try cardContainer.encode("final", forKey: .document_step)
            try cardContainer.encode(tokenFront, forKey: .document_token_front)
            try cardContainer.encode(tokenBack, forKey: .document_token_back)
        case let .finalPassport(passportToken):
            try cardContainer.encode("final", forKey: .document_step)
            try cardContainer.encode(passportToken, forKey: .document_token_front)
        }
    }
}

internal enum AlloyCardEvaluationStep {
    case front(AlloyDocumentToken)
    case back(AlloyDocumentToken)
    case finalID(AlloyDocumentToken, AlloyDocumentToken)
    case finalPassport(AlloyDocumentToken)
}

public struct AlloyCardEvaluationResponse: Codable {
    public let entityToken: AlloyEntityToken
    public let summary: Summary

    public struct Summary: Codable {
        public let outcome: String
        public let outcomeReasons: [String]

        var isApproved: Bool {
            outcome == Constants.approvedOutcome
        }

        private enum CodingKeys: String, CodingKey {
            case outcome = "outcome",
                 outcomeReasons = "outcome_reasons"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case entityToken = "entity_token",
             summary
    }
}

private enum Constants {
    static let approvedOutcome = "Approved"
}
