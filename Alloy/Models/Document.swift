import Foundation

typealias AlloyDocumentToken = String

enum AlloyDocumentExtension: String, Codable {
    case jpg, png, pdf
}

enum AlloyDocumentType: String, Codable {
    case contract, license, passport, utility
}

struct AlloyDocumentPayload: Codable {
    let name: String
    let `extension`: AlloyDocumentExtension
    let type: AlloyDocumentType
    var note: String? = nil
    var noteAuthorAgentEmail: String? = nil

    private enum CodingKeys: String, CodingKey {
        case name,
             `extension`,
             type,
             note,
             noteAuthorAgentEmail = "note_author_agent_email"
    }
}

struct AlloyDocumentUpload {
    let token: AlloyDocumentToken
    let `extension`: AlloyDocumentExtension
    let imageData: Data
}

struct AlloyDocument: Codable {
    let token: AlloyDocumentToken
    let uploaded: Bool

    private enum CodingKeys: String, CodingKey {
        case token = "document_token",
             uploaded
    }
}
