import Foundation

internal extension Bundle {
    static let alloy: Bundle = {
        let myBundle = Bundle(for: AlloyViewController.self)

        guard let resourceBundleURL = myBundle.url(forResource: "AlloyAssets", withExtension: "bundle"),
           let resourceBundle = Bundle(url: resourceBundleURL) else {
               return Bundle.main
        }

        return resourceBundle
    }()
}
