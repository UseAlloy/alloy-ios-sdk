import UIKit

internal class MainViewController: UIViewController {
    public var api: API!
    public var entityToken: String?

    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(close))
        return button
    }()

    private lazy var preview = UIImageView()

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
        return view
    }()

    private lazy var backCard: CardDetail = {
        let view = CardDetail()
        view.takeButton.setTitle("Take back", for: .normal)
        view.takeButton.addTarget(self, action: #selector(takeBackPicture), for: .touchUpInside)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        title = "Scan your ID"
        view.backgroundColor = .white

        navigationItem.leftBarButtonItem = closeButton

        view.addSubview(preview)
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        preview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        preview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        preview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        view.addSubview(subheadline)
        subheadline.translatesAutoresizingMaskIntoConstraints = false
        subheadline.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        subheadline.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        subheadline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

        view.addSubview(cardsStack)
        cardsStack.translatesAutoresizingMaskIntoConstraints = false
        cardsStack.topAnchor.constraint(equalTo: subheadline.bottomAnchor, constant: 40).isActive = true
        cardsStack.leadingAnchor.constraint(equalTo: subheadline.leadingAnchor).isActive = true
        cardsStack.trailingAnchor.constraint(equalTo: subheadline.trailingAnchor).isActive = true
        cardsStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true

        cardsStack.addArrangedSubview(frontCard)
        cardsStack.addArrangedSubview(backCard)
    }

    // MARK: Actions

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func takeFrontPicture() {
        self.takePicture(for: "Front side", storeIn: frontCard.preview)
    }

    @objc private func takeBackPicture() {
        self.takePicture(for: "Back side", storeIn: backCard.preview)
    }

    private func takePicture(for title: String, storeIn preview: UIImageView) {
        let vc = CameraViewController()
        vc.title = title
        vc.imageTaken = { [weak self, weak preview] data in
            let image = UIImage(data: data)
            preview?.image = image
            self?.createDocument(data: data, for: title)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: Alloy Actions

    private func createDocument(data: Data, for side: String) {
        guard let api = api, let entityToken = entityToken else { return }

        let documentData = AlloyDocumentData(name: "license", extension: "jpg", type: "license")
        api.create(document: documentData, andUpload: data, for: entityToken) { result in
            switch result {
            case let .failure(error):
                print("create/upload", error)
            case let .success(response):
                let evaluation = AlloyCardEvaluationData(entityToken: entityToken, evaluationStep: .back(response.token))
                api.evaluate(document: evaluation) { result in
                    switch result {
                    case let .failure(error):
                        print("evaluate", error)
                    case let .success(response):
                        print(">", response.summary.outcome)
                    }
                }
            }
        }
    }
}
