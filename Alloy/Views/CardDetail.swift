import UIKit

class CardDetail: UIView {
    // MARK: Views

    internal var preview: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    private var bottomSheet: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.Theme.white
        view.layer.cornerRadius = 10
        return view
    }()

    internal var takeButton: UIButton = {
        let view = UIButton(type: .system)
        return view
    }()

    private var statusContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.Theme.blue
        view.layer.cornerRadius = 10
        return view
    }()

    private var statusIcon: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor.Theme.white
        return view
    }()

    private var problemIcon: UIImageView = {
        let image = UIImage(fallbackSystemImage: "exclamationmark.circle")
        let view = UIImageView(image: image)
        view.isHidden = true
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor.Theme.black
        return view
    }()

    private var problemLabel: UILabel = {
        let view = UILabel()
        view.isHidden = true
        view.font = .systemFont(ofSize: 17)
        view.numberOfLines = 0
        return view
    }()

    private var retakeButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = true
        button.setTitle("Retake", for: .normal)
        button.setTitleColor(UIColor.Theme.blue, for: .normal)
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
        layer.borderColor = UIColor(red: 0.95, green: 0.96, blue: 1, alpha: 1).cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 20
        clipsToBounds = true

        addSubview(preview)
        addSubview(bottomSheet)
        addSubview(takeButton)
        addSubview(statusContainer)
        addSubview(statusIcon)
        addSubview(problemIcon)
        addSubview(problemLabel)
        addSubview(retakeButton)

        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        preview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        preview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        preview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
        bottomSheet.heightAnchor.constraint(equalToConstant: 44).isActive = true
        bottomSheet.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        bottomSheet.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        bottomSheet.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true

        takeButton.translatesAutoresizingMaskIntoConstraints = false
        takeButton.centerXAnchor.constraint(equalTo: bottomSheet.centerXAnchor).isActive = true
        takeButton.centerYAnchor.constraint(equalTo: bottomSheet.centerYAnchor).isActive = true

        statusContainer.translatesAutoresizingMaskIntoConstraints = false
        statusContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true
        statusContainer.widthAnchor.constraint(equalToConstant: 44).isActive = true
        statusContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        statusContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true

        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.heightAnchor.constraint(equalToConstant: 28).isActive = true
        statusIcon.widthAnchor.constraint(equalToConstant: 28).isActive = true
        statusIcon.centerXAnchor.constraint(equalTo: statusContainer.centerXAnchor).isActive = true
        statusIcon.centerYAnchor.constraint(equalTo: statusContainer.centerYAnchor).isActive = true

        problemIcon.translatesAutoresizingMaskIntoConstraints = false
        problemIcon.heightAnchor.constraint(equalToConstant: 24).isActive = true
        problemIcon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        problemIcon.centerYAnchor.constraint(equalTo: bottomSheet.centerYAnchor).isActive = true
        problemIcon.leadingAnchor.constraint(equalTo: bottomSheet.leadingAnchor, constant: 8).isActive = true

        problemLabel.translatesAutoresizingMaskIntoConstraints = false
        problemLabel.centerYAnchor.constraint(equalTo: bottomSheet.centerYAnchor).isActive = true
        problemLabel.leadingAnchor.constraint(equalTo: problemIcon.trailingAnchor, constant: 8).isActive = true
        problemLabel.trailingAnchor.constraint(lessThanOrEqualTo: retakeButton.leadingAnchor, constant: 8).isActive = true

        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        retakeButton.centerYAnchor.constraint(equalTo: bottomSheet.centerYAnchor).isActive = true
        retakeButton.trailingAnchor.constraint(equalTo: bottomSheet.trailingAnchor, constant: -16).isActive = true
    }

    // MARK: Configure

    public func startLoading() {
        bottomSheet.isHidden = true
        takeButton.isHidden = true
        problemLabel.isHidden = true
        problemIcon.isHidden = true
        retakeButton.isHidden = true
        statusContainer.isHidden = false
        statusIcon.isHidden = false
        statusIcon.image = UIImage(fallbackSystemImage: "arrow.2.circlepath")
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat, .curveLinear], animations: { [weak self] in
            guard let self = self else { return }
            self.statusIcon.transform = self.statusIcon.transform.rotated(by: .pi)
        })
    }

    public func issueAppeared(_ issue: String) {
        statusContainer.isHidden = true
        statusIcon.isHidden = true
        takeButton.isHidden = true
        bottomSheet.isHidden = false
        problemIcon.isHidden = false
        problemLabel.isHidden = false
        problemLabel.text = issue
        retakeButton.isHidden = false
    }

    public func approved() {
        takeButton.isHidden = true
        bottomSheet.isHidden = true
        problemIcon.isHidden = true
        problemLabel.isHidden = true
        retakeButton.isHidden = true
        statusContainer.isHidden = false
        statusContainer.backgroundColor = UIColor.Theme.green
        statusIcon.isHidden = false
        statusIcon.image = UIImage(fallbackSystemImage: "checkmark")
        statusIcon.layer.removeAllAnimations()
        statusIcon.layer.transform = CATransform3DIdentity
        layer.borderColor = UIColor.Theme.green.cgColor
    }
}
