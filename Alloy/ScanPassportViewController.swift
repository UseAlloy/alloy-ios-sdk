import UIKit

class ScanPassportViewController: UIViewController {
    // MARK: Views

    private lazy var backButton: UIBarButtonItem = {
        let image = UIImage(fallbackSystemImage: "arrow.left")
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(onBack))
    }()

    private lazy var helpButton: UIBarButtonItem = {
        let image = UIImage(fallbackSystemImage: "questionmark.circle")
        return UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
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
    }

    // MARK: Actions

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }
}
