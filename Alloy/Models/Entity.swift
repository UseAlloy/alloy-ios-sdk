import Foundation

public typealias AlloyEntityToken = String

struct AlloyEntity: Codable {
    let token: AlloyEntityToken
    let nameFirst: String
    let nameLast: String
}
