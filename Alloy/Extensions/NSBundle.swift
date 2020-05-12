import Foundation

internal extension Bundle {
    static var alloy: Bundle {
        return Bundle(for: AlloyViewController.self)
    }
}
