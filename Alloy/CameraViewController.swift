import AVFoundation
import UIKit

internal class CameraViewController: UIViewController {
    public var imageTaken: ((Data) -> Void)?

    // MARK: Camera Views

    private var session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        return session
    }()

    private var photoOutput = AVCapturePhotoOutput()
    private lazy var videoPreviewLayer: CALayer = {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoOrientation = .portrait
        return layer
    }()

    // MARK: Views

    private lazy var backButton: UIBarButtonItem = {
        let image = UIImage(fallbackSystemImage: "arrow.left")
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(goBack))
    }()

    private lazy var overlay: UIView = {
        let view = UIView()
        view.alpha = 0.6
        view.backgroundColor = UIColor.Theme.black
        return view
    }()

    private lazy var subheadline: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15)
        view.numberOfLines = 0
        view.text = "Fit your ID card inside the frame and take the picture."
        view.textAlignment = .center
        view.textColor = UIColor.Theme.white
        return view
    }()

    private lazy var cardFrame: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.Theme.white.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 20
        return view
    }()

    private lazy var shutterButton: UIButton = {
        let image = UIImage(named: "shutterButton")
        let view = UIButton(type: .system)
        view.setImage(image, for: .normal)
        view.tintColor = UIColor.Theme.white
        view.addTarget(self, action: #selector(onShutter), for: .touchUpInside)
        return view
    }()

    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupCamera()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    private func setup() {
        view.backgroundColor = .black

        navigationItem.leftBarButtonItem = backButton

        view.addSubview(overlay)
        view.addSubview(subheadline)
        view.addSubview(cardFrame)
        view.addSubview(shutterButton)

        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        subheadline.translatesAutoresizingMaskIntoConstraints = false
        subheadline.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64).isActive = true
        subheadline.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 64).isActive = true
        subheadline.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -64).isActive = true

        cardFrame.translatesAutoresizingMaskIntoConstraints = false
        cardFrame.heightAnchor.constraint(equalToConstant: 168).isActive = true
        cardFrame.widthAnchor.constraint(equalToConstant: 295).isActive = true
        cardFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cardFrame.topAnchor.constraint(equalTo: subheadline.bottomAnchor, constant: 72).isActive = true

        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.heightAnchor.constraint(equalToConstant: 66).isActive = true
        shutterButton.widthAnchor.constraint(equalToConstant: 66).isActive = true
        shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
    }

    private func setupCamera() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back
        )

        guard let device = discoverySession.devices.first else {
            return
        }

        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        if session.canAddInput(input) && session.canAddOutput(photoOutput) {
            session.addInput(input)
            session.addOutput(photoOutput)
            setupLivePreview()
        }
    }

    private func setupLivePreview() {
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
        videoPreviewLayer.frame = view.layer.frame

        self.session.startRunning()
        self.session.commitConfiguration()
    }

    // MARK: Actions

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onShutter() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.videoPreviewLayer.frame = self.view.layer.frame
        overlay.maskRemove(cardFrame)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }

        imageTaken?(imageData)
        navigationController?.popViewController(animated: true)
    }
}
