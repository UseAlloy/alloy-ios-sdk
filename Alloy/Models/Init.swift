import Foundation
import class UIKit.UIViewController

internal struct AlloyInitPayload: Codable {
    let id: String
    let domain: String
}

internal struct AlloyInitResponse: Codable {
    let accessToken: String

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

public struct Alloy {
    let key: String
    let evaluationData: AlloyEvaluationData
    public var entityToken: AlloyEntityToken? = nil
    public var externalEntityId: AlloyEntityToken? = nil
    public var maxEvaluationAttempts: Int = 2
    public var production: Bool = false

    public init(key: String, for evaluationData: AlloyEvaluationData) {
        self.key = key
        self.evaluationData = evaluationData
    }

    public func open(in parent: UIViewController) {
        let vc = AlloyViewController(with: self)
        parent.present(vc, animated: true)
    }
}
