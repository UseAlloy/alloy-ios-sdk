import UIKit

internal class ScanBaseViewController: UIViewController {
    internal var numberOfAttempts = 0
    internal var isSelfieHidden = true {
        didSet {
            selfiePreview.isHidden = isSelfieHidden
            selfieSwitcher.isSelfieHidden = isSelfieHidden
        }
    }

    internal var evaluationData: AlloyEvaluationData? {
        return config.evaluationData
    }

    internal var needsPreChecks: Bool {
        config.validationPreChecks
    }

    // MARK: Views

    internal lazy var scrollView = UIScrollView()
    internal lazy var contentView = UIView()

    internal lazy var selfiePreview: SelfieDetail = {
        let view = SelfieDetail()
        view.isHidden = true
        view.retakeButton.addTarget(self, action: #selector(takeSelfiePicture), for: .touchUpInside)
        return view
    }()

    internal lazy var selfieSwitcher: SelfieSwitcher = {
        let view = SelfieSwitcher()
        view.isHidden = true
        return view
    }()

    internal lazy var mainButton: UIButton = {
        let button = PrimaryButton(title: "Send pictures")
        button.isHidden = true
        return button
    }()

    // MARK: Init properties

    internal var api: API!
    internal var config: Alloy!

    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: Setup

    internal func setup() {
        view.backgroundColor = .white

        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.heightAnchor.constraint(greaterThanOrEqualTo: safeArea.heightAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }

    // MARK: Actions

    internal func showEndScreen(for response: AlloyResult, onRetry: (() -> Void)?) {
        numberOfAttempts += 1

        let vc = EndViewController()
        vc.onRetry = onRetry
        vc.response = response
        vc.onCompletion = config.completion
        vc.noMoreAttempts = numberOfAttempts >= config.maxEvaluationAttempts
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc internal func takeSelfiePicture() {
        let vc = CameraViewController()
        vc.variant = .selfie
        vc.imageTaken = { [weak self] uiImage in
            self?.mainButton.setTitle("Send pictures", for: .normal)
            self?.selfiePreview.preview.image = uiImage
            self?.selfiePreview.retakeButton.isHidden = false
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
