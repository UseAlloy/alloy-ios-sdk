import UIKit

public class AlloyViewController: UINavigationController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        let vc = MainViewController()
        pushViewController(vc, animated: false)
    }
}
