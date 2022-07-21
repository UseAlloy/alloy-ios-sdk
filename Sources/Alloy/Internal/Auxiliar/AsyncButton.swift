//
//  AsyncButton.swift
//
//
//  Created by Marc Hervera on 10/2/22.
//

import SwiftUI

internal struct AsyncButton<Label: View>: View {
    
    // MARK: - Properties
    var loadingColor: Color = .accentColor
    var action: () async -> Void
    @ViewBuilder var label: () -> Label
    
    @State private var isLoading = false

    // MARK: - Override
    public var body: some View {
        
        Button {
            
            isLoading = true
            Task {
                
                await action()
                isLoading = false
                
            }
            
        } label: {
            
            if isLoading {
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: loadingColor))
                
            } else { label() }
            
        }
        .disabled(isLoading)
        .animation(.spring(), value: isLoading)
        
    }
    
}
