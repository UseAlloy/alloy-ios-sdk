import UIKit

class GetStartedViewController: UIViewController {
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
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

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
    }

    @objc private func closeModal() {
        dismiss(animated: true)
    }

    @objc private func getStarted() {
        let vc = MainViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
