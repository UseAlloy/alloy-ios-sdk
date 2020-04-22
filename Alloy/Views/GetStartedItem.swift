import UIKit

class GetStartedItem: UIView {
    private let image: UIImageView = {
        let image = UIImage(named: "daylight")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        return view
    }()

    private var title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()

    private let label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15)
        view.numberOfLines = 0
        view.textAlignment = .natural
        view.textColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1)
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
        addSubview(image)
        addSubview(title)
        addSubview(label)

        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(lessThanOrEqualToConstant: 55).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor).isActive = true
        image.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true

        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 80).isActive = true
        title.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4).isActive = true
        label.leadingAnchor.constraint(equalTo: title.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    internal func configure(image: String, title: String?, description: String?) {
        self.image.image = UIImage(named: image)
        self.title.text = title
        self.label.text = description
    }
}
