import UIKit

internal class SelectDocumentViewController: UIViewController {
    // MARK: Init properties

    var api: API!
    var config: Alloy!

    // MARK: Views

    private lazy var closeButton: UIBarButtonItem = {
        let image = UIImage(fallbackSystemImage: "xmark")
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(close))
    }()

    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15, weight: .regular)
        view.numberOfLines = 0
        view.text = "You can scan your ID or passport. Keep the document close and make sure it is in good condition."
        view.textAlignment = .center
        view.textColor = UIColor.Theme.black
        return view
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 24
        return stack
    }()

    private lazy var buttons: [DocumentRadioButton] = {
        return DocumentRadioButton.Variant.allCases.map { variant in
            let button = DocumentRadioButton(variant: variant)
            button.addTarget(self, action: #selector(toggleSelection), for: .touchUpInside)
            return button
        }
    }()

    private lazy var continueButton: UIButton = {
        let button = PrimaryButton(title: "Continue")
        button.isHidden = true
        button.addTarget(self, action: #selector(onContinue), for: .touchUpInside)
        return button
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
        title = "Select document"
        view.backgroundColor = .white

        navigationItem.leftBarButtonItem = closeButton

        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(descriptionLabel)
        view.addSubview(buttonStack)
        view.addSubview(continueButton)

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20).isActive = true

        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 48).isActive = true
        buttonStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40).isActive = true
        buttonStack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40).isActive = true

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40).isActive = true
        continueButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40).isActive = true
        continueButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -40).isActive = true

        for button in buttons {
            buttonStack.addArrangedSubview(button)
        }
    }

    // MARK: Actions

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func toggleSelection(_ sender: UIButton) {
        for button in buttons {
            button.isSelected = false
        }

        sender.isSelected = true
        continueButton.isHidden = false
    }

    @objc private func onContinue() {
        guard let selected = buttons.first(where: \.isSelected),
              let variant = selected.variant
        else { return }

        switch variant {
        case .passport:
            let vc = ScanPassportViewController()
            vc.api = api
            vc.config = config
            navigationController?.pushViewController(vc, animated: true)
        case .id:
            let vc = ScanIDViewController()
            vc.api = api
            vc.config = config
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
