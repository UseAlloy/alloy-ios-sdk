import UIKit

internal class AlloyViewController: UINavigationController {
    public init(with config: Alloy) {
        let vc = GetStartedViewController()
        vc.config = config
        super.init(rootViewController: vc)
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = .black
    }
}
