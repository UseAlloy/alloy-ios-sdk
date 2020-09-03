import UIKit

internal class DocumentRadioButton: UIButton {
    enum Variant: CaseIterable {
        case passport, id
    }

    var variant: Variant!

    override var isSelected: Bool {
        didSet {
            configureIsSelected(isSelected)
        }
    }

    // MARK: Views

    private let icon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = false
        return view
    }()

    private let label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15, weight: .semibold)
        view.numberOfLines = 0
        view.textColor = UIColor.Theme.black
        return view
    }()

    private let check: UIImageView = {
        let view = UIImageView(image: UIImage(fallbackSystemImage: "checkmark"))
        view.tintColor = UIColor.Theme.blue
        view.alpha = 0
        view.isUserInteractionEnabled = false
        return view
    }()

    // MARK: Init

    convenience init(variant: Variant) {
        self.init(type: .system)
        setup()
        configure(variant)
    }

    // MARK: Setup

    private func setup() {
        tintColor = .clear
        layer.borderColor = UIColor.Theme.border.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 12

        addSubview(icon)
        addSubview(label)
        addSubview(check)

        heightAnchor.constraint(equalToConstant: 64).isActive = true

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.heightAnchor.constraint(equalToConstant: 40).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 40).isActive = true
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 18).isActive = true
        label.trailingAnchor.constraint(lessThanOrEqualTo: check.leadingAnchor, constant: -18).isActive = true

        check.translatesAutoresizingMaskIntoConstraints = false
        check.heightAnchor.constraint(equalToConstant: 20).isActive = true
        check.widthAnchor.constraint(equalToConstant: 20).isActive = true
        check.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        check.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }

    private func configure(_ variant: Variant) {
        self.variant = variant
        switch variant {
        case .passport:
            label.text = "Passport"
            icon.image = UIImage(named: "passport")
        case .id:
            label.text = "ID card"
            icon.image = UIImage(named: "idcard")
        }
    }

    private func configureIsSelected(_ isSelected: Bool) {
        let duration = 0.15
        let toColor = isSelected ? UIColor.Theme.blue.cgColor : UIColor.Theme.border.cgColor

        UIView.animate(withDuration: duration) { [weak self] in
            self?.check.alpha = isSelected ? 1 : 0
        }

        let keyPath = "borderColor"
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = layer.borderColor
        animation.toValue = toColor
        animation.duration = duration
        layer.add(animation, forKey: keyPath)
        layer.borderColor = toColor
    }
}
