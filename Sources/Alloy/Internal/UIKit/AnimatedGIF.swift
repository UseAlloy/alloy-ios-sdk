//
//  AnimatedGIF.swift
//  
//
//  Created by Marc Hervera on 19/5/22.
//

import SwiftUI
import WebKit

struct AnimatedGIF: UIViewRepresentable {

    // MARK: - Properties
    private let name: String
    
    // MARK: Override
    init(_ name: String) {
        self.name = name
    }
    
    func makeUIView(context: Context) -> WKWebView {
        
        let webView = WKWebView()
        webView.isOpaque = false

        if let url = Bundle.module.url(forResource: name, withExtension: "gif"), let data = try? Data(contentsOf: url) {
            webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
        }
        
        return webView
        
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
}

extension AnimatedGIF {
    
    init(_ identifier: Image.Identifier) {
        self.init("\(identifier)")
    }
    
}

