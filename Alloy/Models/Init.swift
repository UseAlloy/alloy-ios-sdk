import Foundation

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
