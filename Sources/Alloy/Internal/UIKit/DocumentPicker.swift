//
//  DocumentPicker.swift
//  
//
//  Created by Marc Hervera on 13/5/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

internal struct DocumentPicker: UIViewControllerRepresentable {
    
    // MARK: - Properties
    @Binding var selectedFileURL: URL?
    
    // MARK: - Override
    func makeUIViewController(context: Context) -> some UIViewController {
        
        let types: [UTType] = [.pdf]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker

    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
        
    }
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        
        DocumentPickerCoordinator(url: $selectedFileURL)
        
    }
    
}

internal class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    
    // MARK: - Properties
    @Binding var fileURL: URL?
    
    init(url: Binding<URL?>) {
        
        _fileURL = url
        
    }
    
    // MARK: - UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        self.fileURL = url
        
    }
    
}
