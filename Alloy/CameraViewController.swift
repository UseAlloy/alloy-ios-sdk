import UIKit

internal class CameraViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        title = "Front side"
        view.backgroundColor = .black
    }
}
