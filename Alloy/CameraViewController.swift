import AVFoundation
import UIKit

internal class CameraViewController: UIViewController {
    enum Variant {
        case id, passport, selfie

        var cropHeightRatio: CGFloat {
            switch self {
            case .id, .passport:
                return 0.618

            case .selfie:
                return 1.2
            }
        }
    }

    // MARK: Public Properties

    public var imageTaken: ((CGImage) -> Void)?
    public var variant: Variant = .id

    // MARK: Camera Views

    private var session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        return session
    }()

    private var currentCameraPosition: AVCaptureDevice.Position = .back
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
        view.textAlignment = .center
        view.textColor = UIColor.Theme.white
        return view
    }()

    private lazy var cropRegion: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.Theme.white.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 20
        return view
    }()

    private lazy var cameraAccessIcon: UIImageView = {
        let image = UIImage(named: "video.slash")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        view.tintColor = UIColor.Theme.white
        return view
    }()

    private lazy var cameraAccessLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0.6
        label.font = .systemFont(ofSize: 15)
        label.isHidden = true
        label.numberOfLines = 0
        label.text = "Please allow camera access in Settings > Privacy"
        label.textAlignment = .center
        label.textColor = UIColor.Theme.white
        return label
    }()

    private lazy var toggleCameraButton: UIButton = {
        let image = UIImage(fallbackSystemImage: "camera.rotate")
        let view = UIButton(type: .system)
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        view.tintColor = UIColor.Theme.white
        view.addTarget(self, action: #selector(toggleCamera), for: .touchUpInside)
        return view
    }()

    private lazy var shutterButton: UIButton = {
        let image = UIImage(named: "shutterButton")
        let view = UIButton(type: .system)
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
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

    override var shouldAutorotate: Bool { false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupVariant()
        checkCameraPermissions()
    }

    private func setup() {
        view.backgroundColor = .black

        navigationItem.leftBarButtonItem = backButton

        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(overlay)
        view.addSubview(subheadline)
        view.addSubview(cropRegion)
        view.addSubview(cameraAccessIcon)
        view.addSubview(cameraAccessLabel)
        view.addSubview(toggleCameraButton)
        view.addSubview(shutterButton)
        view.addSubview(flashButton)

        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        subheadline.translatesAutoresizingMaskIntoConstraints = false
        subheadline.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 64).isActive = true
        subheadline.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 64).isActive = true
        subheadline.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -64).isActive = true

        setupCropRegion()

        cameraAccessIcon.translatesAutoresizingMaskIntoConstraints = false
        cameraAccessIcon.heightAnchor.constraint(equalToConstant: 52).isActive = true
        cameraAccessIcon.widthAnchor.constraint(equalToConstant: 64).isActive = true
        cameraAccessIcon.centerXAnchor.constraint(equalTo: cropRegion.centerXAnchor).isActive = true
        cameraAccessIcon.centerYAnchor.constraint(equalTo: cropRegion.centerYAnchor).isActive = true

        cameraAccessLabel.translatesAutoresizingMaskIntoConstraints = false
        cameraAccessLabel.topAnchor.constraint(equalTo: cropRegion.bottomAnchor, constant: 16).isActive = true
        cameraAccessLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 66).isActive = true
        cameraAccessLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -66).isActive = true

        toggleCameraButton.translatesAutoresizingMaskIntoConstraints = false
        toggleCameraButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        toggleCameraButton.widthAnchor.constraint(equalToConstant: 26).isActive = true
        toggleCameraButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor).isActive = true
        toggleCameraButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40).isActive = true

        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.heightAnchor.constraint(equalToConstant: 66).isActive = true
        shutterButton.widthAnchor.constraint(equalToConstant: 66).isActive = true
        shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shutterButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -40).isActive = true

        flashButton.translatesAutoresizingMaskIntoConstraints = false
        flashButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        flashButton.widthAnchor.constraint(equalToConstant: 26).isActive = true
        flashButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor).isActive = true
        flashButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40).isActive = true
    }

    private func setupVariant() {
        switch variant {
        case .selfie:
            title = "Selfie time"
            subheadline.text = "Fit yourself in the frame and take the picture."

        case .passport:
            title = "Passport"
            subheadline.text = "Fit your passport inside the frame and take the picture."

        case .id:
            subheadline.text = "Fit your ID card inside the frame and take the picture."
        }
    }

    private func checkCameraPermissions() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            setupCamera(position: currentCameraPosition)
            return
        }

        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if granted {
                    self.setupCamera(position: self.currentCameraPosition)
                } else {
                    self.setupNoCamera()
                }
            }
        }
    }

    private func setupCropRegion() {
        let cropWidthRatio: CGFloat = 0.8
        let cropHeightRatio = cropWidthRatio * variant.cropHeightRatio

        cropRegion.translatesAutoresizingMaskIntoConstraints = false
        cropRegion.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: cropHeightRatio
        ).isActive = true
        cropRegion.widthAnchor.constraint(
            greaterThanOrEqualTo: view.widthAnchor,
            multiplier: cropWidthRatio
        ).isActive = true
        cropRegion.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cropRegion.topAnchor.constraint(equalTo: subheadline.bottomAnchor, constant: 40).isActive = true
    }

    private func setupCamera(position: AVCaptureDevice.Position) {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )

        guard let device = discoverySession.devices.first else {
            return
        }

        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        setupLivePreview()
    }

    private func setupLivePreview() {
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
        videoPreviewLayer.frame = view.layer.frame

        self.session.startRunning()
        self.session.commitConfiguration()
        setupYesCamera()
    }

    private func setupYesCamera() {
        let views = [cameraAccessIcon, cameraAccessLabel]
        let buttons = [toggleCameraButton, shutterButton, flashButton]

        DispatchQueue.main.async { [weak self] in
            self?.cropRegion.backgroundColor = .clear

            for view in views {
                view.isHidden = true
            }

            for button in buttons {
                button.isEnabled = true
                button.alpha = 1
            }
        }
    }

    private func setupNoCamera() {
        let views = [cameraAccessIcon, cameraAccessLabel]
        let buttons = [toggleCameraButton, shutterButton, flashButton]

        DispatchQueue.main.async { [weak self] in
            self?.cropRegion.backgroundColor = UIColor.Theme.white.withAlphaComponent(0.2)

            for view in views {
                view.isHidden = false
            }

            for button in buttons {
                button.isEnabled = false
                button.alpha = 0.7
            }
        }
    }

    // MARK: Actions

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onShutter() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @objc private func toggleCamera() {
        var newPosition: AVCaptureDevice.Position = .back

        if let input = session.inputs.first {
            session.removeInput(input)
            if (input as? AVCaptureDeviceInput)?.device.position == .back {
                newPosition = .front
            }
        }

        setupCamera(position: newPosition)
        currentCameraPosition = newPosition
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
            @unknown default:
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
        overlay.maskRemove(cropRegion)

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
        let flip = currentCameraPosition == .front
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
        guard let image = UIImage(data: imageData)?.rotate(radians: radians, flip: flip) else { return }
        guard let cropped = crop(image, for: variant) else { return }

        imageTaken?(cropped)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Image Cropping

private func crop(_ uiimage: UIImage, for variant: CameraViewController.Variant) -> CGImage? {
    guard let image = uiimage.cgImage else {
        return .none
    }

    let height = Double(image.height)
    let width = Double(image.width)

    let rect = CGRect(
        x: width * 0.1,
        y: height * 0.3,
        width: width * 0.8,
        height: (width * 0.8) * Double(variant.cropHeightRatio)
    )

    guard let cropped = image.cropping(to: rect) else {
        return nil
    }

    return cropped
}
