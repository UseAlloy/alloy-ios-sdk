import Foundation

internal extension Bundle {
    static let alloy: Bundle = {
        let myBundle = Bundle(for: AlloyViewController.self)

        guard let resourceBundleURL = myBundle.url(
            forResource: "AlloyAssets", withExtension: "bundle")
            else { fatalError("AlloyAssets.bundle not found!") }

        guard let resourceBundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access AlloyAssets.bundle!") }

        return resourceBundle
    }()
}
