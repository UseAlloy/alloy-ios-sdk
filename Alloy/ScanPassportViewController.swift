import UIKit

internal class ScanPassportViewController: ScanBaseViewController {
    // MARK: Views

    private lazy var backButton: UIBarButtonItem = {
        let image = UIImage(fallbackSystemImage: "arrow.left")
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(onBack))
    }()

    private lazy var helpButton: UIBarButtonItem = {
        let image = UIImage(fallbackSystemImage: "questionmark.circle")
        return UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
    }()

    private lazy var subheadline: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 15)
        view.text = "Open your passport and take a picture from inside. It may take a while to validate your personal information."
        view.textAlignment = .center
        return view
    }()

    private lazy var passportPicture: CardDetail = {
        let view = CardDetail()
        view.preview.image = UIImage(named: "Front Card Placeholder")
        view.takeButton.setTitle("Take picture", for: .normal)
        view.takeButton.addTarget(self, action: #selector(takePassportPicture), for: .touchUpInside)
        view.retakeButton.addTarget(self, action: #selector(takePassportPicture), for: .touchUpInside)
        return view
    }()
    
    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: Setup

    private func setup() {
        title = "Scan your passport"
        view.backgroundColor = .white

        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = helpButton

        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(subheadline)
        view.addSubview(passportPicture)

        subheadline.translatesAutoresizingMaskIntoConstraints = false
        subheadline.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40).isActive = true
        subheadline.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20).isActive = true
        subheadline.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20).isActive = true

        passportPicture.translatesAutoresizingMaskIntoConstraints = false
        passportPicture.heightAnchor.constraint(equalToConstant: 190).isActive = true
        passportPicture.topAnchor.constraint(equalTo: subheadline.bottomAnchor, constant: 40).isActive = true
        passportPicture.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40).isActive = true
        passportPicture.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40).isActive = true

    }

    // MARK: Actions

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func takePassportPicture() {
        let vc = CameraViewController()
        vc.title = "Passport"
        vc.imageTaken = { [weak self] cgImage in
            let image = UIImage(cgImage: cgImage)
            self?.passportPicture.preview.image = image
            self?.passportPicture.startLoading()
            if let self = self, let data = image.jpegData(compressionQuality: 0.9) {
                self.createDocument(data: data)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func createDocument(data: Data) {
    }
}
