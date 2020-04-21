import UIKit

class EndBanner: UIView {
    public var variant: EndVariant = .success {
        didSet {
            changeVariant()
        }
    }

    // MARK: Views

    private var outerCircle: UIView = {
        let view = UIView()
        view.alpha = 0.05
        view.layer.cornerRadius = 74
        return view
    }()

    private var midCircle: UIView = {
        let view = UIView()
        view.alpha = 0.08
        view.layer.cornerRadius = 55
        return view
    }()

    private var innerCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 37.5
        return view
    }()

    private var iconContainer: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor.Theme.white
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
        addSubview(outerCircle)
        addSubview(midCircle)
        addSubview(innerCircle)
        addSubview(iconContainer)

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 148).isActive = true
        widthAnchor.constraint(equalToConstant: 148).isActive = true

        outerCircle.translatesAutoresizingMaskIntoConstraints = false
        outerCircle.heightAnchor.constraint(equalToConstant: 148).isActive = true
        outerCircle.widthAnchor.constraint(equalToConstant: 148).isActive = true
        outerCircle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        outerCircle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        midCircle.translatesAutoresizingMaskIntoConstraints = false
        midCircle.heightAnchor.constraint(equalToConstant: 110).isActive = true
        midCircle.widthAnchor.constraint(equalToConstant: 110).isActive = true
        midCircle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        midCircle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.heightAnchor.constraint(equalToConstant: 75).isActive = true
        innerCircle.widthAnchor.constraint(equalToConstant: 75).isActive = true
        innerCircle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        innerCircle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.heightAnchor.constraint(equalToConstant: 26).isActive = true
        iconContainer.widthAnchor.constraint(equalToConstant: 26).isActive = true
        iconContainer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iconContainer.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    // MARK: Configure

    private func changeVariant() {
        let color = variant == .failure ? UIColor.Theme.red : UIColor.Theme.green
        outerCircle.backgroundColor = color
        midCircle.backgroundColor = color
        innerCircle.backgroundColor = color
        iconContainer.image = variant == .failure
            ? UIImage(fallbackSystemImage: "xmark")
            : UIImage(fallbackSystemImage: "checkmark")
    }
}
