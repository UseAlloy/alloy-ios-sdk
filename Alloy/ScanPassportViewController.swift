import UIKit

internal class ScanPassportViewController: ScanBaseViewController {
    private var passportToken: AlloyDocumentToken? {
        didSet {
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
        view.preview.image = UIImage(named: "Front Card Placeholder")
        view.takeButton.setTitle("Take picture", for: .normal)
        view.takeButton.addTarget(self, action: #selector(takePassportPicture), for: .touchUpInside)
        view.retakeButton.addTarget(self, action: #selector(takePassportPicture), for: .touchUpInside)
        return view
    }()

    private lazy var sendButton: UIButton = {
        let button = PrimaryButton(title: "Send Pictures")
        button.isHidden = true
        button.addTarget(self, action: #selector(validatePassport), for: .touchUpInside)
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
        title = "Scan your passport"
        view.backgroundColor = .white

        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = helpButton

        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(subheadline)
        view.addSubview(passportPicture)
        view.addSubview(sendButton)
        view.addSubview(retryButton)

        subheadline.translatesAutoresizingMaskIntoConstraints = false
        subheadline.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40).isActive = true
        subheadline.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20).isActive = true
        subheadline.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20).isActive = true

        passportPicture.translatesAutoresizingMaskIntoConstraints = false
        passportPicture.heightAnchor.constraint(equalToConstant: 190).isActive = true
        passportPicture.topAnchor.constraint(equalTo: subheadline.bottomAnchor, constant: 40).isActive = true
        passportPicture.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40).isActive = true
        passportPicture.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40).isActive = true

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: retryButton.topAnchor, constant: -20).isActive = true

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        retryButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40).isActive = true
        retryButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40).isActive = true
        retryButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -40).isActive = true
    }

    // MARK: Actions

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func takePassportPicture() {
        let vc = CameraViewController()
        vc.title = "Passport"
        vc.imageTaken = { [weak self] cgImage in
            let image = UIImage(cgImage: cgImage)
            self?.passportPicture.preview.image = image
            self?.passportPicture.startLoading()
            if let self = self, let data = image.jpegData(compressionQuality: 0.9) {
                self.createDocument(data: data)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func createDocument(data: Data) {
        guard let api = api, let evaluationData = evaluationData else { return }

        let documentData = AlloyDocumentPayload(name: "passport", extension: .jpg, type: .passport)
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
                            if responseE.summary.outcome == "Approved" {
                                self?.passportPicture.approved()
                                self?.passportToken = response.token
                            }
                        }
                    }
                }
            }
        }
    }

    @objc private func validatePassport() {
    }
}
