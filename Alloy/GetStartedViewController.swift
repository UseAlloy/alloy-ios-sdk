import UIKit

class GetStartedViewController: UIViewController {
    private var entityToken: AlloyEntityToken? {
        didSet {
            enableGetStarted()
        }
    }

    public var api: API!
    public var target: AlloyEvaluationTarget?

    // MARK: Views

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 22, weight: .bold)
        view.numberOfLines = 0
        view.text = "We have a few tips to make this process easier"
        view.textAlignment = .center
        return view
    }()

    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = 30
        return view
    }()

    private lazy var getStartedButton: UIButton = {
        let view = PrimaryButton(title: "Get Started")
        view.addTarget(self, action: #selector(getStarted), for: .touchUpInside)
        view.alpha = 0
        return view
    }()

    private lazy var loader: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
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
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: Setup

    private func setup() {
        view.backgroundColor = UIColor.Theme.white

        view.addSubview(titleLabel)
        view.addSubview(stack)
        view.addSubview(getStartedButton)
        view.addSubview(loader)
        view.addSubview(cancelButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50).isActive = true

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60).isActive = true
        stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true

        let item1 = GetStartedItem()
        item1.configure(
            image: "checkid",
            title: "Check your ID",
            description: "Keep your ID close and make sure it is in good condition."
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

        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        getStartedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        getStartedButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
        getStartedButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true
        getStartedButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -20).isActive = true

        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.centerYAnchor.constraint(equalTo: getStartedButton.centerYAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: getStartedButton.centerXAnchor).isActive = true
        loader.startAnimating()

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
    }

    // MARK: Data

    private func loadData() {
        switch target {
        case .existing(let token):
            self.entityToken = token
        case .new(let data):
            api.evaluate(data, completion: evaluationCompletion)
        case .none:
            closeModal()
        }
    }

    private func evaluationCompletion(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        guard let data = data, let parsed = try? JSONDecoder().decode(AlloyEvaluationResponse.self, from: data) else {
            closeModal()
            return
        }

        self.entityToken = parsed.entityToken
    }

    // MARK: Actions

    @objc private func closeModal() {
        dismiss(animated: true)
    }

    @objc private func getStarted() {
        let vc = MainViewController()
        vc.api = api
        vc.entityToken = entityToken
        navigationController?.pushViewController(vc, animated: true)
    }

    private func enableGetStarted() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.getStartedButton.alpha = 1
                self?.loader.stopAnimating()
            }
        }
    }
}
