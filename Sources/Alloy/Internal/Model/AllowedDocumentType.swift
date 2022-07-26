import Foundation

public enum AllowedDocumentType: String {

    case passport
    case license
    case canadaProvincialID = "canada_provincial_id"
    case indigenousCard = "indigenous_card"
    case paystub
    case bankStatement = "bank_statement"
    case docW2 = "w2"
    case doc1099 = "1099"
    case doc1120 = "1120"
    case doc1065 = "1065"
    case docT1 = "t1"
    case docT4 = "t4"

}

extension AllowedDocumentType {
    func map() -> DocumentType {
        guard let documentType = DocumentType(rawValue: self.rawValue) else {
            return .none
        }
        return documentType
    }
}
