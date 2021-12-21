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

    public init(nameFirst: String, nameLast: String) {
        self.nameFirst = nameFirst
        self.nameLast = nameLast
        self.addressLine1 = nil
        self.addressLine2 = nil
        self.addressCity = nil
        self.addressState = nil
        self.addressPostalCode = nil
        self.addressCountryCode = nil
        self.birthDate = nil
    }

    private enum CodingKeys: String, CodingKey {
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
        case name_first,
             name_last,
             document_step,
             document_token_front,
             document_token_back
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(evaluationData.nameFirst, forKey: .name_first)
        try container.encode(evaluationData.nameLast, forKey: .name_last)

        switch evaluationStep {
        case let .front(token):
            try container.encode("front", forKey: .document_step)
            try container.encode(token, forKey: .document_token_front)
        case let .back(token):
            try container.encode("back", forKey: .document_step)
            try container.encode(token, forKey: .document_token_back)
        case let .finalID(tokenFront, tokenBack):
            try container.encode("final", forKey: .document_step)
            try container.encode(tokenFront, forKey: .document_token_front)
            try container.encode(tokenBack, forKey: .document_token_back)
        case let .finalPassport(passportToken):
            try container.encode("final", forKey: .document_step)
            try container.encode(passportToken, forKey: .document_token_front)
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
