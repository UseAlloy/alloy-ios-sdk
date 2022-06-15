//
//  BottomPadding.swift
//
//
//  Created by Marc Hervera on 8/5/22.
//

import SwiftUI

internal extension UIApplication {
    
    var keyWindow: UIWindow? {
        
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
    }
    
}

internal struct BottomPadding: ViewModifier {
    
    private let bottomSpace: CGFloat
    
    init(space: CGFloat) {
        self.bottomSpace = space
    }
    
    func body(content: Content) -> some View {
        
        let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        content.padding(.bottom, safeAreaInsets.bottom > 0 ? bottomSpace : 32)
        
    }
    
}

internal extension View {
    
    func adjustBottomPadding(space: CGFloat = 0) -> some View {
        
        modifier(BottomPadding(space: space))
        
    }
    
}
