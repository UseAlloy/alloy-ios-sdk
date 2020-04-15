import UIKit

internal class MainViewController: UIViewController {
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(close))
        return button
    }()

    private lazy var subheadline: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 15)
        view.text = "Take a photo of both sides. It may take time to validate your personal information."
        view.textAlignment = .center
        return view
    }()

    private lazy var frontButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Take front", for: .normal)
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        return button
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Take back", for: .normal)
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        title = "Scan your ID"
        view.backgroundColor = .white

        navigationItem.leftBarButtonItem = closeButton

        view.addSubview(subheadline)
        subheadline.translatesAutoresizingMaskIntoConstraints = false
        subheadline.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        subheadline.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        subheadline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

        view.addSubview(frontButton)
        frontButton.translatesAutoresizingMaskIntoConstraints = false
        frontButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        frontButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backButton.topAnchor.constraint(equalTo: frontButton.bottomAnchor, constant: 24).isActive = true
    }

    // MARK: Actions

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func openCamera() {
        let vc = CameraViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
