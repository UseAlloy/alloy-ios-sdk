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

public enum AlloyEvaluationTarget {
    case new(AlloyEvaluationData)
    case existing(AlloyEntityToken)
}

public struct Alloy {
    let key: String
    public var externalEntityId: String? = nil
    let evaluationTarget: AlloyEvaluationTarget
    public var maxEvaluationAttempts: Int = 2
    public var production: Bool = false

    public init(key: String, for evaluationTarget: AlloyEvaluationTarget) {
        self.key = key
        self.evaluationTarget = evaluationTarget
    }

    public func open(in parent: UIViewController) {
        let vc = AlloyViewController(with: self)
        parent.present(vc, animated: true)
    }
}
