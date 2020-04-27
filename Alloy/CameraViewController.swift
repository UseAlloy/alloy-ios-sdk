import AVFoundation
import UIKit

internal class CameraViewController: UIViewController {
    public var imageTaken: ((CGImage) -> Void)?

    // MARK: Camera Views

    private var session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        return session
    }()

    private var photoOutput = AVCapturePhotoOutput()
    private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspect
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

    private lazy var flashButton: UIButton = {
        let image = UIImage(fallbackSystemImage: "bolt.fill")
        let view = UIButton(type: .system)
        view.setImage(image, for: .normal)
        view.tintColor = UIColor.Theme.white
        view.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
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
        view.addSubview(flashButton)

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
        cardFrame.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true
        cardFrame.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor, multiplier: 0.8).isActive = true
        cardFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cardFrame.topAnchor.constraint(equalTo: subheadline.bottomAnchor, constant: 72).isActive = true

        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.heightAnchor.constraint(equalToConstant: 66).isActive = true
        shutterButton.widthAnchor.constraint(equalToConstant: 66).isActive = true
        shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true

        flashButton.translatesAutoresizingMaskIntoConstraints = false
        flashButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        flashButton.widthAnchor.constraint(equalToConstant: 26).isActive = true
        flashButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor).isActive = true
        flashButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
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

    @objc private func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard device.hasTorch else { return }

        try? device.lockForConfiguration()
        defer {
            device.unlockForConfiguration()
            let image: UIImage?
            switch device.torchMode {
            case .on, .auto:
                image = UIImage(fallbackSystemImage: "bolt.slash.fill")
            case .off:
                image = UIImage(fallbackSystemImage: "bolt.fill")
            }
            flashButton.setImage(image, for: .normal)
        }

        if (device.torchMode == .on) {
            device.torchMode = .off
            return
        }

        try? device.setTorchModeOn(level: 1.0)
    }

    // MARK: Layout Subviews

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Calculate new overlay mark
        overlay.maskRemove(cardFrame)

        // Update preview frame and orientation based on device orientation
        self.videoPreviewLayer.frame = self.view.layer.frame
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .landscapeLeft:
            videoPreviewLayer.connection?.videoOrientation = .landscapeRight
        case .landscapeRight:
            videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
        case .portraitUpsideDown:
            videoPreviewLayer.connection?.videoOrientation = .portraitUpsideDown
        default:
            videoPreviewLayer.connection?.videoOrientation = .portrait
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        var radians: CGFloat = 0
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            radians = .pi
        case .landscapeLeft:
            radians = .pi / -2
        case .landscapeRight:
            radians = .pi / 2
        default:
            break
        }

        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData)?.rotate(radians: radians) else { return }
        guard let cropped = crop(image) else { return }

        imageTaken?(cropped)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Image Cropping

private func crop(_ uiimage: UIImage) -> CGImage? {
    guard let image = uiimage.cgImage else {
        return .none
    }

    let height = Double(image.height)
    let width = Double(image.width)

    let rect = CGRect(
        x: width * 0.1,
        y: height * 0.2,
        width: width * 0.8,
        height: height * 0.3
    )

    guard let cropped = image.cropping(to: rect) else {
        return nil
    }

    return cropped
}
