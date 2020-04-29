import UIKit

internal enum EndVariant {
    case success
    case failure
}

internal class EndViewController: UIViewController {
    public var noMoreAttempts: Bool = false {
        didSet {
            configureAlloyRetry()
        }
    }

    public var variant: EndVariant = .success {
        didSet {
            configureVariant()
            configureAlloyRetry()
        }
    }

    // MARK: Views

    private lazy var banner: EndBanner = {
        let view = EndBanner()
        view.variant = variant
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 20, weight: .semibold)
        view.textAlignment = .center
        return view
    }()

    private lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 15)
        view.textAlignment = .center
        return view
    }()

    private lazy var mainButton = PrimaryButton(title: "Continue")
    private lazy var leaveButton: UIButton = {
        let view = UIButton(type: .system)
        view.addTarget(self, action: #selector(leave), for: .touchUpInside)
        view.setTitle("Leave, I'll try later", for: .normal)
        view.setTitleColor(UIColor.Theme.blue, for: .normal)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        banner.play()
    }

    private func setup() {
        view.backgroundColor = .white

        view.addSubview(banner)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(mainButton)
        view.addSubview(leaveButton)

        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        banner.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -40).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true

        mainButton.translatesAutoresizingMaskIntoConstraints = false
        mainButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        mainButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        mainButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        mainButton.bottomAnchor.constraint(equalTo: leaveButton.topAnchor, constant: -20).isActive = true

        leaveButton.translatesAutoresizingMaskIntoConstraints = false
        leaveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        leaveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        leaveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        leaveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
    }

    // MARK: Configure

    private func configureVariant() {
        banner.variant = variant
        titleLabel.text = variant == .failure
            ? "Denied"
            : "Success!"
        subtitleLabel.text = variant == .failure
            ? "We’re sorry, your ID cant’t be validated"
            : "Your ID has been validated"
        mainButton.setTitle(variant == .failure ? "Retry" : "Continue", for: .normal)
        leaveButton.isHidden = variant == .success

        // Clear previous action and set new
        mainButton.removeTarget(nil, action: nil, for: .touchUpInside)
        let action = variant == .failure ? #selector(retry) : #selector(leave)
        mainButton.addTarget(self, action: action, for: .touchUpInside)
    }

    private func configureAlloyRetry() {
        mainButton.isHidden = variant == .failure && noMoreAttempts
    }

    // MARK: Actions

    @objc private func retry() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func leave() {
        dismiss(animated: true)
    }
}
