//
//  CroppedImagePicker.swift
//  
//
//  Created by Marc Hervera on 16/5/22.
//

import SwiftUI

internal struct CroppedImagePicker: UIViewControllerRepresentable {
    
    // MARK: - Properties
    @Binding var cropSize: CGSize
    @Binding var croppedImage: UIImage?
    @Binding var cameraDevice: UIImagePickerController.CameraDevice
    @Binding var flashmode: UIImagePickerController.CameraFlashMode
    @Binding var takePicture: Bool
        
    // MARK: - Override
    func makeUIViewController(context: Context) -> UIImagePickerController {
        
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.showsCameraControls = false
        return picker
        
    }
    
    func updateUIViewController(_ picker: UIImagePickerController, context: Context) {
        
        picker.cameraDevice = cameraDevice
        picker.cameraFlashMode = flashmode

        if takePicture {
            picker.takePicture()
        }
        
    }
    
    func makeCoordinator() -> ImagePickerCoordinator {
        
        ImagePickerCoordinator(cropped: $croppedImage, cropSize: $cropSize, takePicture: $takePicture)
        
    }
    
}

internal class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    @Binding var cropped: UIImage?
    @Binding var cropSize: CGSize
    @Binding var takePicture: Bool
    
    // MARK: - Init
    init(cropped: Binding<UIImage?>, cropSize: Binding<CGSize>, takePicture: Binding<Bool>) {
        _cropped = cropped
        _cropSize = cropSize
        _takePicture = takePicture
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        takePicture = false

        let cameraViewSize = CGSize(width: picker.view.bounds.width, height: picker.view.bounds.width * (4/3))
        let origin = CGPoint(
            x: (cameraViewSize.width - cropSize.width) / 2.0,
            y: (cameraViewSize.height - cropSize.height) / 2.0
        )
        let cropRect = CGRect(origin: origin, size: cropSize)
        cropped = cropImage(
            image.fixedOrientation(),
            toRect: cropRect,
            viewWidth: cameraViewSize.width,
            viewHeight: cameraViewSize.height
        )
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        takePicture = false
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}

internal extension ImagePickerCoordinator {
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
        
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)
        
        let cropZone = CGRect(x: cropRect.origin.x * imageViewScale,
                              y: cropRect.origin.y * imageViewScale,
                              width: cropRect.size.width * imageViewScale,
                              height: cropRect.size.height * imageViewScale)
        
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to: cropZone) else {
            return nil
        }

        return UIImage(cgImage: cutImageRef)
        
    }
    
}

#if targetEnvironment(simulator)
internal struct FakeCroppedImagePicker: UIViewControllerRepresentable {
    
    // MARK: - Properties
    var documentType: DocumentOverlayType
    @Binding var croppedImage: UIImage?
    @Binding var takePicture: Bool
        
    // MARK: - Override
    func makeUIViewController(context: Context) -> some UIViewController {
        
        UIViewController()
        
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
        if takePicture {
            
            switch documentType {
            case .passport:
                croppedImage = UIImage(named: "samplePassport", in: .module, with: nil)
                
            case .card(.front):
                croppedImage = UIImage(named: "sampleCardFront", in: .module, with: nil)
                
            case .card(.back):
                croppedImage = UIImage(named: "sampleCardBack", in: .module, with: nil)
                
            case .selfie:
                croppedImage = UIImage(named: "samplePhoto", in: .module, with: nil)
                
            case .pdf:
                croppedImage = nil
                
            }
            
        }
        
        uiViewController.dismiss(animated: true)
        
    }
    
}
#endif
