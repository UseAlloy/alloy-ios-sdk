import Foundation

internal extension Bundle {
    static var alloy: Bundle {
        let bundlePath = Bundle(for: AlloyViewController.self)
            .path(forResource: "AlloyAssets", ofType: "bundle")
        let bundle = Bundle(path: bundlePath ?? "")
        return bundle ?? Bundle.main
    }
}
