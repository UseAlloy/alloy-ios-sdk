import AVFoundation
import UIKit

internal class CameraViewController: UIViewController {
    public var imageTaken: ((Data) -> Void)?

    // MARK: Views

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

    private lazy var shutterButton: UIButton = {
        let view = UIButton(type: .system)
        view.backgroundColor = .white
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

        view.addSubview(shutterButton)
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        shutterButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        shutterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
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

    @objc private func onShutter() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.videoPreviewLayer.frame = self.view.layer.frame
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }

        imageTaken?(imageData)
        navigationController?.popViewController(animated: true)
    }
}
