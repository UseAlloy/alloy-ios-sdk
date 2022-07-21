//
//  DefaultButtonStyle.swift
//
//
//  Created by Marc Hervera on 8/5/22.
//

import SwiftUI

internal struct DefaultButtonStyle: ButtonStyle {
    
    @EnvironmentObject private var configViewModel: ConfigViewModel
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .frame(minWidth: 0, maxWidth: .infinity)
            .font(.headline)
            .background(configuration.isPressed ? configViewModel.theme.button.opacity(0.5) : (isEnabled ? configViewModel.theme.button : configViewModel.theme.button.opacity(0.5)))
            .foregroundColor(.aWhite)
            .cornerRadius(8)
        
    }
    
}
