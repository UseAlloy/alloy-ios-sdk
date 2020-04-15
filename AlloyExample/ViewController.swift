import Alloy
import UIKit

class ViewController: UIViewController {
    let openButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open", for: .normal)
        button.addTarget(self, action: #selector(openAlloy), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(openButton)
        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        openButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    @objc private func openAlloy() {
        let vc = AlloyViewController()
        present(vc, animated: true)
    }
}
