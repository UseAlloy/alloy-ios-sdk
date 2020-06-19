import UIKit

class SelectDocumentViewController: UIViewController {
    // MARK: Init properties

    var api: API!
    var config: Alloy!

    // MARK: Views

    private lazy var closeButton: UIBarButtonItem = {
        let image = UIImage(fallbackSystemImage: "xmark")
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(close))
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
    }

    // MARK: Actions

    @objc private func close() {
        dismiss(animated: true)
    }
}
