import UIKit

internal class PrimaryButton: UIButton {
    static private let backgroundColor = UIColor.Theme.blue
    static private let foregroundColor = UIColor.Theme.white

    internal var isLoading: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isEnabled = !self.isLoading

                if self.isLoading {
                    self.setTitleColor(PrimaryButton.backgroundColor, for: .normal)
                    self.loader.startAnimating()
                } else {
                    self.setTitleColor(PrimaryButton.foregroundColor, for: .normal)
                    self.loader.stopAnimating()
                }
            }
        }
    }

    // MARK: Views

    private lazy var loader: UIActivityIndicatorView = {
        var view: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            view = UIActivityIndicatorView(style: .medium)
            view.color = UIColor.Theme.white
        } else {
            view = UIActivityIndicatorView(style: .white)
        }
        view.hidesWhenStopped = true

        // Add subview here (inside the lazy initializer) instead of in a
        // setup function, to avoid loading this view if never used.
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        return view
    }()

    // MARK: Setup

    convenience init(title: String) {
        self.init(type: .system)

        backgroundColor = PrimaryButton.backgroundColor
        layer.cornerRadius = 8

        // Label
        setTitle(title, for: .normal)
        setTitleColor(PrimaryButton.foregroundColor, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    }
}
