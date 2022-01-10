import UIKit
import CoreMedia

internal enum EndVariant: String {
    case success = "Approved"
    case retakeImages = "Retake Images"
    case manualReview = "Manual Review"
    case failure = "Denied"
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
        if case .failure = response {
            variant = .failure
        }

        if case let .success(alloyResponse) = response {
            variant = alloyResponse.endOutcome
        }
    }

    private func configureVariant() {
        banner.variant = variant
        titleLabel.text = variant.modalTitle
        subtitleLabel.text = variant.message
        mainButton.setTitle(variant.buttonTitle, for: .normal)
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
        if variant == .success || variant == .manualReview {
            leave()
        } else {
            navigationController?.popViewController(animated: true)
            onRetry?()
        }
    }
}

private extension AlloyCardEvaluationResponse {
    var endOutcome: EndVariant {
        EndVariant(rawValue: summary.outcome) ?? .manualReview
    }
}

private extension EndVariant {
    var modalTitle: String {
        switch self {
        case .failure: return "Denied"
        case .success, .manualReview: return "Success"
        case .retakeImages: return "Images need to be retaken"
        }
    }

    var message: String {
        switch self {
        case .failure: return "We’re sorry, your ID cant’t be validated"
        case .success: return "Your ID has been validated"
        case .manualReview: return "Thank you! We're reviewing your images and will get back to you soon"
        case .retakeImages: return "Please, go back and try again"
        }
    }

    var buttonTitle: String {
        switch self {
        case .failure, .retakeImages: return "Retry"
        case .success, .manualReview: return "Finish"
        }
    }
}

