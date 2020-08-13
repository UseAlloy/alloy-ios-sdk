import UIKit

internal class SelfieSwitcher: UIView {
    internal var isSelfieHidden = true {
        didSet {
            showHideButton.setTitle(isSelfieHidden ? "Show" : "Hide", for: .normal)
        }
    }

    // MARK: Views

    private let checkContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.Theme.green
        view.layer.cornerRadius = 12
        return view
    }()

    private let check: UIImageView = {
        let view = UIImageView(image: UIImage(fallbackSystemImage: "checkmark"))
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor.Theme.white
        return view
    }()

    private let label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15, weight: .regular)
        view.numberOfLines = 0
        view.text = "Selfie taken!"
        view.textColor = UIColor.Theme.black
        return view
    }()

    private let showHideButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("Show", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        return view
    }()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: Setup

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.Theme.white
        layer.borderColor = UIColor.Theme.border.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 20

        heightAnchor.constraint(equalToConstant: 64).isActive = true

        addSubview(checkContainer)
        checkContainer.addSubview(check)
        addSubview(label)
        addSubview(showHideButton)

        checkContainer.translatesAutoresizingMaskIntoConstraints = false
        checkContainer.heightAnchor.constraint(equalToConstant: 24).isActive = true
        checkContainer.widthAnchor.constraint(equalToConstant: 24).isActive = true
        checkContainer.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        checkContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18).isActive = true

        check.translatesAutoresizingMaskIntoConstraints = false
        check.heightAnchor.constraint(equalToConstant: 18).isActive = true
        check.widthAnchor.constraint(equalToConstant: 18).isActive = true
        check.centerYAnchor.constraint(equalTo: checkContainer.centerYAnchor).isActive = true
        check.centerXAnchor.constraint(equalTo: checkContainer.centerXAnchor).isActive = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: checkContainer.trailingAnchor, constant: 12).isActive = true

        showHideButton.translatesAutoresizingMaskIntoConstraints = false
        showHideButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        showHideButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        showHideButton.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 16).isActive = true
        showHideButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    }
}
