import UIKit

internal class GetStartedViewController: UIViewController {
    private var api: API!
    private var evaluationData: AlloyEvaluationData? {
        return config.evaluationData
    }

    // MARK: Init properties

    var config: Alloy! {
        didSet {
            if let config = config {
                api = API(config: config)
            }
        }
    }

    // MARK: Views

    internal lazy var scrollView = UIScrollView()
    internal lazy var contentView = UIView()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 22, weight: .bold)
        view.numberOfLines = 0
        view.text = "We have a few tips to make this process easier"
        view.textAlignment = .center
        view.textColor = UIColor.Theme.black
        return view
    }()

    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = 24
        return view
    }()

    private lazy var getStartedButton: PrimaryButton = {
        let view = PrimaryButton(title: "Get Started")
        view.isLoading = true
        view.addTarget(self, action: #selector(getStarted), for: .touchUpInside)
        return view
    }()

    private lazy var cancelButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("Cancel", for: .normal)
        view.setTitleColor(UIColor.Theme.blue, for: .normal)
        view.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        return view
    }()

    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authInit()
    }

    // MARK: Setup

    private func setup() {
        view.backgroundColor = UIColor.Theme.white

        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(stack)
        contentView.addSubview(getStartedButton)
        contentView.addSubview(cancelButton)

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

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 50).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -50).isActive = true

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60).isActive = true
        stack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40).isActive = true
        stack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40).isActive = true

        let item1 = GetStartedItem()
        item1.configure(
            image: "checkid",
            title: "Check your documents",
            description: "Keep it close and make sure it is in good condition."
        )
        stack.addArrangedSubview(item1)

        let item2 = GetStartedItem()
        item2.configure(
            image: "daylight",
            title: "Daylight works best",
            description: "Choose a room with good (indirect) lighting."
        )
        stack.addArrangedSubview(item2)

        let item3 = GetStartedItem()
        item3.configure(
            image: "surroundings",
            title: "Mind your surroundings",
            description: "The clearer the background of the picture is, the better."
        )
        stack.addArrangedSubview(item3)

        let item4 = GetStartedItem()
        item4.configure(
            image: "selfie",
            title: "Be prepared for a selfie",
            description: "This helps us match your face with your ID photo."
        )
        stack.addArrangedSubview(item4)

        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        getStartedButton.topAnchor.constraint(greaterThanOrEqualTo: stack.bottomAnchor, constant: 40).isActive = true
        getStartedButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
        getStartedButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: getStartedButton.bottomAnchor, constant: 20).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40).isActive = true
    }

    // MARK: Data

    private func authInit() {
        api.authInit { [weak self] error in
            if let error = error {
                print(error)
                self?.closeModal()
                return
            }
            self?.enableGetStarted()
        }
    }

    // MARK: Actions

    @objc private func closeModal() {
        DispatchQueue.main.async { [weak self] in
            if let completion = self?.config.completion {
                completion(.success(AlloyCardEvaluationResult(status: .closed)))
            }

            self?.dismiss(animated: true)
        }
    }

    @objc private func getStarted() {
        let vc = SelectDocumentViewController()
        vc.config = config
        vc.api = api
        navigationController?.pushViewController(vc, animated: true)
    }

    private func enableGetStarted() {
        getStartedButton.isLoading = false
    }
}
