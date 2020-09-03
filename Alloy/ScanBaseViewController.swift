import UIKit

internal class ScanBaseViewController: UIViewController {
    internal var numberOfAttempts = 0
    internal var isSelfieHidden = true {
        didSet {
            selfiePreview.isHidden = isSelfieHidden
            selfieSwitcher.isSelfieHidden = isSelfieHidden
        }
    }

    internal var evaluationData: AlloyEvaluationData? {
        return config.evaluationData
    }

    // MARK: Views

    internal lazy var selfiePreview: SelfieDetail = {
        let view = SelfieDetail()
        view.isHidden = true
        return view
    }()

    internal lazy var selfieSwitcher: SelfieSwitcher = {
        let view = SelfieSwitcher()
        view.isHidden = true
        return view
    }()

    // MARK: Init properties

    internal var api: API!
    internal var config: Alloy!

    // MARK: Actions

    internal func showEndScreen(for outcome: EndVariant) {
        numberOfAttempts += 1

        let vc = EndViewController()
        vc.variant = outcome
        vc.noMoreAttempts = numberOfAttempts >= config.maxEvaluationAttempts
        navigationController?.pushViewController(vc, animated: true)
    }
}
