import UIKit

internal class SelfieDetail: UIView {
    // MARK: Views

    internal var preview: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.Theme.white
        view.contentMode = .scaleToFill
        return view
    }()

    internal var retakeButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = true
        button.setTitle("Retake", for: .normal)
        button.setTitleColor(UIColor.Theme.blue, for: .normal)
        button.backgroundColor = UIColor.Theme.white
        button.layer.cornerRadius = 10
        return button
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
        layer.borderColor = UIColor.Theme.border.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 20
        clipsToBounds = true

        addSubview(preview)
        addSubview(retakeButton)

        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        preview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        preview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        preview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        retakeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        retakeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        retakeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        retakeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
}
