import UIKit

public class AlloyViewController: UINavigationController {
    public init(with config: AlloyConfig) {
        let api = API(token: config.applicationToken, secret: config.applicationSecret, production: config.production)
        let vc = GetStartedViewController()
        vc.target = config.evaluationTarget
        vc.api = api
        super.init(rootViewController: vc)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = .black
    }
}
