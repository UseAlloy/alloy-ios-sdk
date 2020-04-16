import UIKit

public class AlloyViewController: UINavigationController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = .black
        let vc = GetStartedViewController()
        pushViewController(vc, animated: false)
    }
}
