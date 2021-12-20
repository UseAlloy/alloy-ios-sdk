import UIKit

internal class ScanIDViewController: ScanBaseViewController {
    private var frontToken: AlloyDocumentToken? {
        didSet {
            backCard.takeButton.isEnabled = frontToken != nil
        }
    }
    private var backToken: AlloyDocumentToken? {
        didSet {
            let isHidden = frontToken == nil || backToken == nil
            mainButton.isHidden = isHidden
            retryButton.isHidden = isHidden
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
        view.restore(with: "Front Card Placeholder")
        view.takeButton.setTitle("Take front", for: .normal)
        view.takeButton.addTarget(self, action: #selector(takeFrontPicture), for: .touchUpInside)
        view.retakeButton.addTarget(self, action: #selector(takeFrontPicture), for: .touchUpInside)
        return view
    }()

    private lazy var backCard: CardDetail = {
        let view = CardDetail()
        view.restore(with: "Back Card Placeholder")
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

    private lazy var retryButton: UIButton = {
        let view = UIButton(type: .system)
        view.isHidden = true
        view.setTitle("Retry", for: .normal)
        view.setTitleColor(UIColor.Theme.blue, for: .normal)
        view.addTarget(self, action: #selector(onRetry), for: .touchUpInside)
        return view
    }()

    // MARK: Setup

    override func setup() {
        super.setup()
        title = "Scan your ID"

        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = helpButton

        contentView.addSubview(subheadline)
        contentView.addSubview(cardsStack)
        cardsStack.addArrangedSubview(frontCard)
        cardsStack.addArrangedSubview(backCard)
        contentView.addSubview(selfiePreview)
        contentView.addSubview(selfieSwitcher)
        contentView.addSubview(mainButton)
        contentView.addSubview(retryButton)

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

        mainButton.addTarget(self, action: #selector(validateBothSides), for: .touchUpInside)
        mainButton.translatesAutoresizingMaskIntoConstraints = false
        mainButton.topAnchor.constraint(greaterThanOrEqualTo: cardsStack.bottomAnchor, constant: 40).isActive = true
        mainButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        mainButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
        mainButton.bottomAnchor.constraint(equalTo: retryButton.topAnchor, constant: -20).isActive = true

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

    @objc private func onRetry() {
        frontToken = nil
        frontCard.restore(with: "Front Card Placeholder")
        backToken = nil
        backCard.restore(with: "Back Card Placeholder")
    }

    private func takePicture(for title: String, card: CardDetail) {
        let vc = CameraViewController()
        vc.title = title
        vc.variant = .id
        vc.imageTaken = { [weak self, weak card] uiImage in
            card?.preview.image = uiImage
            card?.startLoading()
            if let self = self, let card = card, let data = uiImage.jpegData(compressionQuality: 0.9) {
                self.createDocument(data: data, for: card)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: Alloy Actions

    private func createDocument(data: Data, for card: CardDetail) {
        guard let api = api, let evaluationData = evaluationData else { return }

        let documentData = AlloyDocumentPayload(name: "license", extension: .jpg, type: .license)
        api.create(document: documentData, andUpload: data) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                print("create/upload", error)
            case let .success(response):
                guard self.needsPreChecks else {
                    self.assignToken(forCard: card, token: response.token)
                    return
                }

                let evaluation = AlloyCardEvaluationData(evaluationData: evaluationData, evaluationStep: .front(response.token))
                api.evaluate(document: evaluation) { result in
                    switch result {
                    case let .failure(error):
                        print("evaluate", error)
                    case let .success(responseE):
                        guard responseE.summary.isApproved else {
                            self.handleIssue(forCard: card, issue: responseE.summary.outcome)
                            return
                        }
                        self.assignToken(forCard: card, token: response.token)
                    }
                }
            }
        }
    }

    private func assignToken(forCard card: CardDetail, token: String) {
        DispatchQueue.main.async {
            card.approved()

            if card == self.frontCard {
                self.frontToken = token
            }

            if card == self.backCard {
                self.backToken = token
            }
        }
    }

    private func handleIssue(forCard card: CardDetail, issue: String) {
        DispatchQueue.main.async {
            if card == self.frontCard {
                self.frontCard.issueAppeared(issue)
            }

            if card == self.backCard {
                self.backCard.issueAppeared(issue)
            }
        }
    }

    @objc private func validateBothSides() {
        guard let evaluationData = evaluationData, let frontToken = frontToken, let backToken = backToken else {
            mainButton.isHidden = true
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
                self?.showEndScreen(for: .failure(error), onRetry: self?.onRetry)

            case .success(let response):
                DispatchQueue.main.async {
                    let outcome = response.summary.outcome
                    if outcome == "Approved" || outcome == "Denied" {
                        self?.showEndScreen(for: .success(response), onRetry: self?.onRetry)
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
