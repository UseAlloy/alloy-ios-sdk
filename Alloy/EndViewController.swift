import UIKit

internal enum EndVariant {
    case success
    case failure
}

internal class EndViewController: UIViewController {
    // MARK: Init properties

    internal var onRetry: (() -> Void)?
    internal var onCompletion: AlloyResultCallback?
    internal var response: AlloyResult? {
        didSet {
            configureResponse()
        }
    }

    internal var noMoreAttempts: Bool = false {
        didSet {
            configureAlloyRetry()
        }
    }

    private var variant: EndVariant = .success {
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
        view.textColor = UIColor.Theme.black
        return view
    }()

    private lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 15)
        view.textAlignment = .center
        view.textColor = UIColor.Theme.black
        return view
    }()

    private lazy var mainButton: UIButton = {
        let view = PrimaryButton(title: "Continue")
        view.addTarget(self, action: #selector(mainAction), for: .touchUpInside)
        return view
    }()

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

        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(banner)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(mainButton)
        view.addSubview(leaveButton)

        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40).isActive = true
        banner.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        banner.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(greaterThanOrEqualTo: banner.bottomAnchor, constant: 40).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true

        mainButton.translatesAutoresizingMaskIntoConstraints = false
        mainButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        mainButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true

        leaveButton.translatesAutoresizingMaskIntoConstraints = false
        leaveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        leaveButton.topAnchor.constraint(equalTo: mainButton.bottomAnchor, constant: 20).isActive = true
        leaveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        leaveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        leaveButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -40).isActive = true
    }

    // MARK: Configure

    private func configureResponse() {
        switch response {
        case .none:
            break

        case .failure:
            variant = .failure

        case let .success(response):
            if response.summary.outcome == "Approved" {
                variant = .success
            } else if response.summary.outcome == "Denied" {
                variant = .failure
            }
        }
    }

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
    }

    private func configureAlloyRetry() {
        mainButton.isHidden = variant == .failure && noMoreAttempts
    }

    // MARK: Actions

    @objc private func leave() {
        dismiss(animated: true) { [weak self] in
            guard let response = self?.response else { return }
            self?.onCompletion?(response)
        }
    }

    @objc private func mainAction() {
        if variant == .success {
            leave()

        } else {
            navigationController?.popViewController(animated: true)
            onRetry?()
        }
    }
}
