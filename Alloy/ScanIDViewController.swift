import UIKit

internal class ScanIDViewController: ScanBaseViewController {
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

    // MARK: Views

    private lazy var backButton: UIBarButtonItem = {
        let image = UIImage(fallbackSystemImage: "arrow.left")
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(onBack))
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
        view.textColor = UIColor.Theme.black
        return view
    }()
    
    private lazy var frontCard: CardDetail = {
        let view = CardDetail()
        view.preview.image = UIImage(named: "Front Card Placeholder")
        view.takeButton.setTitle("Take front", for: .normal)
        view.takeButton.addTarget(self, action: #selector(takeFrontPicture), for: .touchUpInside)
        view.retakeButton.addTarget(self, action: #selector(takeFrontPicture), for: .touchUpInside)
        return view
    }()

    private lazy var backCard: CardDetail = {
        let view = CardDetail()
        view.preview.image = UIImage(named: "Back Card Placeholder")
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

        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = helpButton

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(subheadline)
        contentView.addSubview(cardsStack)
        cardsStack.addArrangedSubview(frontCard)
        cardsStack.addArrangedSubview(backCard)
        contentView.addSubview(selfiePreview)
        contentView.addSubview(selfieSwitcher)
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

        selfiePreview.translatesAutoresizingMaskIntoConstraints = false
        selfiePreview.topAnchor.constraint(equalTo: cardsStack.topAnchor).isActive = true
        selfiePreview.leadingAnchor.constraint(equalTo: cardsStack.leadingAnchor).isActive = true
        selfiePreview.trailingAnchor.constraint(equalTo: cardsStack.trailingAnchor).isActive = true
        selfiePreview.bottomAnchor.constraint(equalTo: cardsStack.bottomAnchor).isActive = true

        selfieSwitcher.translatesAutoresizingMaskIntoConstraints = false
        selfieSwitcher.topAnchor.constraint(equalTo: cardsStack.topAnchor).isActive = true
        selfieSwitcher.leadingAnchor.constraint(equalTo: cardsStack.leadingAnchor).isActive = true
        selfieSwitcher.trailingAnchor.constraint(equalTo: cardsStack.trailingAnchor).isActive = true

        sendButton.translatesAutoresizingMaskIntoConstraints = false
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

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
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
        vc.imageTaken = { [weak self, weak card] cgImage in
            let image = UIImage(cgImage: cgImage)
            card?.preview.image = image
            card?.startLoading()
            if let self = self, let card = card, let data = image.jpegData(compressionQuality: 0.9) {
                self.createDocument(data: data, for: card)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: Alloy Actions

    private func createDocument(data: Data, for card: CardDetail) {
        guard let api = api, let evaluationData = evaluationData else { return }

        let documentData = AlloyDocumentPayload(name: "license", extension: .jpg, type: .license)
        api.create(document: documentData, andUpload: data) { result in
            switch result {
            case let .failure(error):
                print("create/upload", error)
            case let .success(response):
                let evaluation = AlloyCardEvaluationData(evaluationData: evaluationData, evaluationStep: .front(response.token))
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
        guard let evaluationData = evaluationData, let frontToken = frontToken, let backToken = backToken else {
            sendButton.isHidden = true
            retryButton.isHidden = true
            return
        }

        let evaluation = AlloyCardEvaluationData(
            evaluationData: evaluationData,
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