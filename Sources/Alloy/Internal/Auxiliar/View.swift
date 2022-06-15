//
//  View.swift
//  
//
//  Created by Marc Hervera on 9/5/22.
//

import SwiftUI

internal extension View {
    
    func dismiss() {
        
        UIApplication
            .shared
            .keyWindow?
            .rootViewController?
            .dismiss(animated: true, completion: nil)
        
    }
    
    func errorAlert(error: Binding<OperationError?>) -> some View {
        
        return alert(isPresented: .constant(error.wrappedValue != nil)) {
            
            Alert(
                title: Text("error_title", bundle: .module),
                message: Text(error.wrappedValue?.errorDescription ?? ""),
                dismissButton: .default(Text("ok", bundle: .module), action: {
                    error.wrappedValue = nil
                })
            )
            
        }

    }
    
}
