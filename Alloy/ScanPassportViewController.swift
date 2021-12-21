import UIKit

internal class ScanPassportViewController: ScanBaseViewController {
    private var passportToken: AlloyDocumentToken? {
        didSet {
            let isHidden = passportToken == nil
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
        view.text = "Open your passport and take a picture from inside. It may take a while to validate your personal information."
        view.textAlignment = .center
        view.textColor = UIColor.Theme.black
        return view
    }()

    private lazy var passportPicture: CardDetail = {
        let view = CardDetail()
        view.restore(with: "Front Card Placeholder")
        view.takeButton.setTitle("Take picture", for: .normal)
        view.takeButton.addTarget(self, action: #selector(takePassportPicture), for: .touchUpInside)
        view.retakeButton.addTarget(self, action: #selector(takePassportPicture), for: .touchUpInside)
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
        title = "Scan your passport"

        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = helpButton

        let safeArea = view.safeAreaLayoutGuide
        contentView.addSubview(subheadline)
        contentView.addSubview(passportPicture)
        contentView.addSubview(mainButton)
        contentView.addSubview(retryButton)

        subheadline.translatesAutoresizingMaskIntoConstraints = false
        subheadline.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40).isActive = true
        subheadline.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20).isActive = true
        subheadline.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20).isActive = true

        passportPicture.translatesAutoresizingMaskIntoConstraints = false
        passportPicture.heightAnchor.constraint(equalToConstant: 190).isActive = true
        passportPicture.topAnchor.constraint(equalTo: subheadline.bottomAnchor, constant: 40).isActive = true
        passportPicture.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40).isActive = true
        passportPicture.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40).isActive = true

        mainButton.addTarget(self, action: #selector(validatePassport), for: .touchUpInside)
        mainButton.translatesAutoresizingMaskIntoConstraints = false
        mainButton.topAnchor.constraint(greaterThanOrEqualTo: passportPicture.bottomAnchor, constant: 40).isActive = true
        mainButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40).isActive = true
        mainButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40).isActive = true
        mainButton.bottomAnchor.constraint(equalTo: retryButton.topAnchor, constant: -20).isActive = true

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        retryButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40).isActive = true
        retryButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40).isActive = true
        retryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40).isActive = true
    }

    // MARK: Actions

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func takePassportPicture() {
        let vc = CameraViewController()
        vc.variant = .passport
        vc.imageTaken = { [weak self] uiImage in
            self?.passportPicture.preview.image = uiImage
            self?.passportPicture.startLoading()
            if let self = self, let data = uiImage.jpegData(compressionQuality: 0.9) {
                self.createDocument(data: data)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func onRetry() {
        passportToken = nil
        passportPicture.restore(with: "Front Card Placeholder")
    }

    private func createDocument(data: Data) {
        guard let api = api else { return }

        let documentData = AlloyDocumentPayload(name: "passport", extension: .jpg, type: .passport)

        api.create(document: documentData, andUpload: data) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                print("create/upload", error)
            case let .success(response):
                self.assignToken(token: response.token)
                self.doPreCheckIfNecessary(token: response.token)
            }
        }
    }

    private func assignToken(token: String) {
        DispatchQueue.main.async {
            self.passportPicture.approved()
            self.passportToken = token
        }
    }

    private func handleIssue(issue: String) {
        DispatchQueue.main.async {
            self.passportPicture.issueAppeared(issue)
        }
    }


    private func doPreCheckIfNecessary(token: String) {
        guard needsPreChecks,
              let evaluationData = evaluationData
        else { return }

        let evaluation = AlloyCardEvaluationData(evaluationData: evaluationData, evaluationStep: .front(token))
        api.evaluate(document: evaluation) { [weak self] result in
            switch result {
            case let .failure(error):
                print("evaluate", error)
            case let .success(responseE):
                if !responseE.summary.isApproved {
                    self?.handleIssue(issue: responseE.summary.outcome)
                }
            }
        }
    }

    @objc private func validatePassport() {
        guard let evaluationData = evaluationData, let passportToken = passportToken else {
            mainButton.isHidden = true
            retryButton.isHidden = true
            return
        }

        let evaluation = AlloyCardEvaluationData(
            evaluationData: evaluationData,
            evaluationStep: .finalPassport(passportToken)
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
                        self?.passportPicture.issueAppeared(reason)
                    }
                }
            }
        }
    }
}
