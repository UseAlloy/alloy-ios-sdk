import Foundation

public typealias AlloyEvaluationToken = String
public typealias AlloyEntityToken = String
public typealias AlloyDocumentToken = String

public enum AlloyEvaluationTarget {
    case new(AlloyEvaluationData)
    case existing(AlloyEntityToken)
}

public struct AlloyConfig {
    // let key: String
    // let externalEntityId: String?
    let applicationToken: String
    let applicationSecret: String
    let evaluationTarget: AlloyEvaluationTarget
    var maxEvaluationAttempts: Int = 2
    var production: Bool = false

    public init(token: String, secret: String, for evaluationTarget: AlloyEvaluationTarget) {
        self.applicationToken = token
        self.applicationSecret = secret
        self.evaluationTarget = evaluationTarget
    }
}

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

internal struct AlloyDocumentData: Codable {
    let name: String
    let `extension`: String
    let type: String // ‘contract’, ‘license’, ‘passport’, or ‘utility’
    // var note: String? = nil
    // var note_author_agent_email: String? = nil
}

internal struct AlloyDocumentResponse: Decodable {
    let token: AlloyDocumentToken
    let uploaded: Bool

    private enum CodingKeys: String, CodingKey {
        case token = "document_token",
             uploaded
    }
}

internal struct AlloyCardEvaluationData {
    let entityToken: AlloyEntityToken
    let evaluationStep: AlloyCardEvaluationStep
}

internal enum AlloyCardEvaluationStep: Encodable {
    case front(AlloyDocumentToken)
    case back(AlloyDocumentToken)
    case both(AlloyDocumentToken, AlloyDocumentToken)

    private enum CodingKeys: String, CodingKey {
        case document_step,
             document_token_front,
             document_token_back
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .front(token):
            try container.encode("front", forKey: .document_step)
            try container.encode(token, forKey: .document_token_front)
        case let .back(token):
            try container.encode("back", forKey: .document_step)
            try container.encode(token, forKey: .document_token_back)
        case let .both(tokenFront, tokenBack):
            try container.encode("both", forKey: .document_step)
            try container.encode(tokenFront, forKey: .document_token_front)
            try container.encode(tokenBack, forKey: .document_token_back)
        }
    }
}

internal struct AlloyCardEvaluationResponse: Codable {
    let entityToken: AlloyEntityToken
    let summary: Summary

    internal struct Summary: Codable {
        let outcome: String
    }

    private enum CodingKeys: String, CodingKey {
        case entityToken = "entity_token",
             summary
    }
}