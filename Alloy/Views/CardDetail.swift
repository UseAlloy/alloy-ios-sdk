import UIKit

class CardDetail: UIView {
    // MARK: Views

    internal var preview: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    internal var takeButton: UIButton = {
        let view = UIButton(type: .system)
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
        layer.borderColor = UIColor(red: 0.95, green: 0.96, blue: 1, alpha: 1).cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 20
        clipsToBounds = true

        addSubview(preview)
        addSubview(takeButton)

        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        preview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        preview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        preview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        takeButton.translatesAutoresizingMaskIntoConstraints = false
        takeButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        takeButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        takeButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        takeButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
