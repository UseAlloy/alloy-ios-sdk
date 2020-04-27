import UIKit

internal class AlloyViewController: UINavigationController {
    public init(with config: Alloy) {
        let api = API(id: config.key, production: config.production)
        let vc = GetStartedViewController()
        vc.target = config.evaluationTarget
        vc.api = api
        super.init(rootViewController: vc)
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
