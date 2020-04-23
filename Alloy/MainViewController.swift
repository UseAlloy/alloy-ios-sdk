import UIKit

internal class MainViewController: UIViewController {
    public var api: API!
    public var entityToken: String?

    private var frontToken: AlloyDocumentToken? {
        didSet {
            guard frontToken != nil else { return }
            backCard.takeButton.isEnabled = true
        }
    }
    private var backToken: AlloyDocumentToken? {
        didSet {
            guard frontToken != nil, backToken != nil else { return }
            sendButton.isHidden = false
            retryButton.isHidden = false
        }
    }

    private lazy var closeButton: UIBarButtonItem = {
        let image = UIImage(fallbackSystemImage: "xmark")
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(close))
    }()

    private lazy var helpButton: UIBarButtonItem = {
        let image = UIImage(fallbackSystemImage: "questionmark.circle")
        return UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
    }()

    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()

    private lazy var subheadline: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 15)
        view.text = "Take a photo of both sides. It may take time to validate your personal information."
        view.textAlignment = .center
        return view
    }()
    
    private lazy var frontCard: CardDetail = {
        let view = CardDetail()
        view.takeButton.setTitle("Take front", for: .normal)
        view.takeButton.addTarget(self, action: #selector(takeFrontPicture), for: .touchUpInside)
        view.retakeButton.addTarget(self, action: #selector(takeFrontPicture), for: .touchUpInside)
        return view
    }()

    private lazy var backCard: CardDetail = {
        let view = CardDetail()
        view.takeButton.setTitle("Take back", for: .normal)
        view.takeButton.addTarget(self, action: #selector(takeBackPicture), for: .touchUpInside)
        view.takeButton.isEnabled = false
        view.retakeButton.addTarget(self, action: #selector(takeBackPicture), for: .touchUpInside)
        return view
    }()

    private lazy var cardsStack: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = 20
        return view
    }()

    private lazy var sendButton: UIButton = {
        let button = PrimaryButton(title: "Send Pictures")
        button.isHidden = true
        button.addTarget(self, action: #selector(validateBothSides), for: .touchUpInside)
        return button
    }()

    private lazy var retryButton: UIButton = {
        let view = UIButton(type: .system)
        view.isHidden = true
        view.setTitle("Retry", for: .normal)
        view.setTitleColor(UIColor.Theme.blue, for: .normal)
        return view
    }()

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

    private func setup() {
        title = "Scan your ID"
        view.backgroundColor = .white

        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = helpButton

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(subheadline)
        contentView.addSubview(cardsStack)
        cardsStack.addArrangedSubview(frontCard)
        cardsStack.addArrangedSubview(backCard)
        contentView.addSubview(sendButton)
        contentView.addSubview(retryButton)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

        subheadline.translatesAutoresizingMaskIntoConstraints = false
        subheadline.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40).isActive = true
        subheadline.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        subheadline.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true

        cardsStack.translatesAutoresizingMaskIntoConstraints = false
        cardsStack.heightAnchor.constraint(equalToConstant: 400).isActive = true
        cardsStack.topAnchor.constraint(equalTo: subheadline.bottomAnchor, constant: 40).isActive = true
        cardsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        cardsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.topAnchor.constraint(greaterThanOrEqualTo: cardsStack.bottomAnchor, constant: 40).isActive = true
        sendButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: retryButton.topAnchor, constant: -20).isActive = true

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        retryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        retryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
        retryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40).isActive = true
    }

    // MARK: Actions

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func takeFrontPicture() {
        self.takePicture(for: "Front side", card: frontCard)
    }

    @objc private func takeBackPicture() {
        self.takePicture(for: "Back side", card: backCard)
    }

    private func takePicture(for title: String, card: CardDetail) {
        let vc = CameraViewController()
        vc.title = title
        vc.imageTaken = { [weak self, weak card] data in
            let image = UIImage(data: data)
            card?.preview.image = image
            card?.startLoading()
            if let self = self, let card = card {
                self.createDocument(data: data, for: card)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showEndScreen(for outcome: EndVariant) {
        let vc = EndViewController()
        vc.variant = outcome
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: Alloy Actions

    private func createDocument(data: Data, for card: CardDetail) {
        guard let api = api, let entityToken = entityToken else { return }

        let documentData = AlloyDocumentPayload(name: "license", extension: .jpg, type: .license)
        api.create(document: documentData, andUpload: data, for: entityToken) { result in
            switch result {
            case let .failure(error):
                print("create/upload", error)
            case let .success(response):
                let evaluation = AlloyCardEvaluationData(entity: AlloyEntity(token: entityToken, nameFirst: "John", nameLast: "Doe"), evaluationStep: .back(response.token))
                api.evaluate(document: evaluation) { result in
                    switch result {
                    case let .failure(error):
                        print("evaluate", error)
                    case let .success(responseE):
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            if responseE.summary.outcome == "Approved" {
                                card.approved()
                                if card == self.frontCard {
                                    self.frontToken = response.token
                                } else {
                                    self.backToken = response.token
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @objc private func validateBothSides() {
        guard let entityToken = entityToken, let frontToken = frontToken, let backToken = backToken else {
            sendButton.isHidden = true
            retryButton.isHidden = true
            return
        }

        let evaluation = AlloyCardEvaluationData(
            entity: AlloyEntity(token: entityToken, nameFirst: "John", nameLast: "Retakeglarefront"),
            evaluationStep: .both(frontToken, backToken)
        )

        api.evaluate(document: evaluation) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                DispatchQueue.main.async {
                    if response.summary.outcome == "Approved" {
                        self?.showEndScreen(for: .success)
                        return
                    }

                    if response.summary.outcome == "Denied" {
                        self?.showEndScreen(for: .failure)
                        return
                    }

                    for reason in response.summary.outcomeReasons {
                        if reason.starts(with: "Back") {
                            self?.backCard.issueAppeared(reason)
                        } else if reason.starts(with: "Front") {
                            self?.frontCard.issueAppeared(reason)
                        }
                    }
                }
            }
        }
    }
}
