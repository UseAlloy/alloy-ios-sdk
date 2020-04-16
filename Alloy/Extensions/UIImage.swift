import class UIKit.UIImage

internal extension UIImage {
    convenience init?(fallbackSystemImage name: String) {
        if #available(iOS 13.0, *) {
            self.init(systemName: name)
        } else {
            self.init(named: name)
        }
    }
}
