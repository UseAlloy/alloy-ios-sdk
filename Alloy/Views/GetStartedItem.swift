import UIKit

class GetStartedItem: UIView {
    private let stack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .top
        view.distribution = .fillProportionally
        view.spacing = 16
        return view
    }()

    private let image: UIImageView = {
        let image = UIImage(fallbackSystemImage: "checkmark.circle")
        let view = UIImageView(image: image)
        view.tintColor = UIColor.Theme.green
        return view
    }()

    private let label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16)
        view.numberOfLines = 0
        view.textAlignment = .natural
        view.textColor = UIColor.Theme.black
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

    private func setup() {
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        stack.addArrangedSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.heightAnchor.constraint(equalToConstant: 24).isActive = true
        image.widthAnchor.constraint(equalToConstant: 24).isActive = true

        stack.addArrangedSubview(label)
    }

    internal func configure(with text: String?) {
        label.text = text
    }
}
