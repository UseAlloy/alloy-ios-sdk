//
//  ScanDocumentView.swift
//  
//
//  Created by Marc Hervera on 16/5/22.
//

import SwiftUI

internal enum DocumentOverlayType: Equatable {
    case passport
    case card(Variant)
    case selfie
    case pdf

    enum Variant {
        case front
        case back
    }
    
    var cameraOverlayHorizontalPadding: CGFloat {
        
        switch self {
        case .passport, .selfie:
            return 60
            
        case .card(.front), .card(.back):
            return 30
            
        case .pdf:
            return 20
            
        }
        
    }
    
    var cameraOverlaRatio: CGFloat {
        
        switch self {
        case .passport:
            return 0.714
            
        case .card(.front), .card(.back):
            return 1.586
        
        case .selfie:
            return 0.812
            
        case .pdf:
            return 0.707
            
        }
        
    }
    
}

internal struct ScanDocumentView: View {
    
    // MARK: - Properties
    var documentOverlayType: DocumentOverlayType
    @Binding var image: UIImage?
    
    @State private var flashMode: UIImagePickerController.CameraFlashMode = .off
    @State private var takePicture = false
    @State private var cropSize: CGSize = .zero
    @EnvironmentObject private var configViewModel: ConfigViewModel
    
    // MARK: - Main
    var body: some View {
        
        ZStack {

            #if targetEnvironment(simulator)
            FakeCroppedImagePicker(
                documentType: documentOverlayType,
                croppedImage: $image,
                takePicture: $takePicture
            )
            #else
            CroppedImagePicker(
                cropSize: $cropSize,
                croppedImage: $image,
                cameraDevice: (documentOverlayType == .selfie) ? .constant(.front) : .constant(.rear),
                flashmode: $flashMode,
                takePicture: $takePicture
            )
            #endif

            DocumentOverlay(
                documentOverlayType: documentOverlayType,
                cropSize: $cropSize
            )
            
            VStack(spacing: 20) {
                
                instructions(type: documentOverlayType)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 30)
                    .padding(.horizontal, 40 )
                
                CameraControls(
                    flashMode: $flashMode,
                    takePicture: $takePicture
                )
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.horizontal, 30)
            .padding(.bottom, 20)

        }
        .background(
            Color
                .black
                .edgesIgnoringSafeArea(.all)
        )
        
    }
    
    func instructions(type: DocumentOverlayType) -> Text {
        
        var title = ""
        switch documentOverlayType {
        case .passport:
            title = "scan_document_passport_instructions"

        case .card:
            title = "scan_document_card_instructions"
            
        case .selfie:
            title = "scan_document_selfie_instructions"
            
        default:
            title = ""
            
        }
        
        return Text(LocalizedStringKey(title), bundle: .module)
        
    }
    
}

private struct DocumentOverlay: View {
    
    // MARK: - Properties
    var documentOverlayType: DocumentOverlayType
    @Binding var cropSize: CGSize
    
    // MARK: - Main
    var body: some View {
        
        ZStack {
            
            ZStack {
                
                Rectangle()
                    .fill(Color.blue)

                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black)
                    .aspectRatio(documentOverlayType.cameraOverlaRatio, contentMode: .fit)
                    .padding(.horizontal, documentOverlayType.cameraOverlayHorizontalPadding)
                
            }
            .compositingGroup()
            .luminanceToAlpha()
            
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 2)
                .aspectRatio(documentOverlayType.cameraOverlaRatio, contentMode: .fit)
                .padding(.horizontal, documentOverlayType.cameraOverlayHorizontalPadding)
                .overlay(
                    GeometryReader { proxy in
                        Text("")
                            .onAppear {
                                cropSize = CGSize(
                                    width: proxy.size.width - (documentOverlayType.cameraOverlayHorizontalPadding * 2),
                                    height: proxy.size.height)
                            }
                        
                    }
                )
            
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 1.3333, alignment: .top)
        .frame(maxHeight: .infinity, alignment: .top)
        
    }
    
}

private struct CameraControls: View {
    
    // MARK: - Properties
    @Binding var flashMode: UIImagePickerController.CameraFlashMode
    @Binding var takePicture: Bool
    
    @Environment(\.presentationMode) private var presentation
    
    // MARK: - Main
    var body: some View {
        
        HStack {
                        
            Button {
                
                presentation.wrappedValue.dismiss()
                
            } label: {
                
                Text("Cancel")
                    .font(.title3)
                    .foregroundColor(.white)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
            
            Button {
                
                takePicture = true
                
            } label: {
                
                ZStack {
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50, alignment: .center)
                        .overlay(
                        
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 55, height: 55, alignment: .center)
                            
                        )
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()

            Button {
                
                flashMode = flashMode == .off ? .on : .off
                
            } label: {
                
                Image(flashMode == .on ? .boltSlashFill : .boltFill)
                    .font(.title2)
                    .foregroundColor(.white)
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
        }
        
    }
    
}

struct ScanDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        ScanDocumentView(documentOverlayType: .passport, image: .constant(nil))
    }
}
