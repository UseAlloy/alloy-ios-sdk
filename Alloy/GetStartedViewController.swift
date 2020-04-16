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

    private lazy var closeButton: UIBarButtonItem = {
        let image = UIImage(fallbackSystemImage: "xmark")
        return UIBarButtonItem(image: image, style: .done, target: self, action: #selector(closeModal))
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

    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadData()
    }

    // MARK: Setup

    private func setup() {
        title = "Get Started"
        view.backgroundColor = UIColor.Theme.white

        navigationItem.leftBarButtonItem = closeButton

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true

        let item1 = GetStartedItem()
        item1.configure(with: "Keep your ID close and make sure it is in good condition.")
        stack.addArrangedSubview(item1)

        let item2 = GetStartedItem()
        item2.configure(with: "Choose a room with good (indirect) lighting. Daylight works best.")
        stack.addArrangedSubview(item2)

        let item3 = GetStartedItem()
        item3.configure(with: "Mind your surroundings, the clearer the background of the picture is, the better.")
        stack.addArrangedSubview(item3)

        view.addSubview(getStartedButton)
        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        getStartedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        getStartedButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
        getStartedButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true
        getStartedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -106).isActive = true

        view.addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.centerYAnchor.constraint(equalTo: getStartedButton.centerYAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: getStartedButton.centerXAnchor).isActive = true
        loader.startAnimating()
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
        vc.entitiToken = entityToken
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
