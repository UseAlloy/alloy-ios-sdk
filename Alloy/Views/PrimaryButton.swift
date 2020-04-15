import UIKit

internal class PrimaryButton: UIButton {
    convenience init(title: String) {
        self.init(type: .system)
        backgroundColor = UIColor.Theme.blue
        layer.cornerRadius = 8

        // Label
        setTitle(title, for: .normal)
        setTitleColor(UIColor.Theme.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    }
}
