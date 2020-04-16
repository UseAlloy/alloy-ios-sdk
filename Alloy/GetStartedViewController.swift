import UIKit

class GetStartedViewController: UIViewController {
    private lazy var closeButton: UIBarButtonItem = {
        let image = UIImage(fallbackSystemImage: "xmark")
        return UIBarButtonItem(image: image, style: .done, target: self, action: #selector(closeModal))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        title = "Get Started"
        view.backgroundColor = UIColor.Theme.white

        navigationItem.leftBarButtonItem = closeButton
    }

    @objc private func closeModal() {
        dismiss(animated: true)
    }
}
