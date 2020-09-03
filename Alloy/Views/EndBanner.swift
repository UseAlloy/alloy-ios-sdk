import Lottie
import UIKit

internal class EndBanner: UIView {
    public var variant: EndVariant = .success {
        didSet {
            changeVariant()
        }
    }

    // MARK: Views

    private lazy var animationView: AnimationView = {
        let view = AnimationView()
        return view
    }()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: Setup

    private func setup() {
        addSubview(animationView)

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        animationView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        animationView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    // MARK: Configure

    private func changeVariant() {
        let animation = Animation.named(variant == .success ? "EndSuccess" : "EndFailure", bundle: .alloy)
        animationView.animation = animation
    }

    // MARK: Actions

    internal func play() {
        animationView.play()
    }
}
