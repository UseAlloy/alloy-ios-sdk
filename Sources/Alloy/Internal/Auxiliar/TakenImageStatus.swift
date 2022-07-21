//
//  TakenImageStatus.swift
//  
//
//  Created by Marc Hervera on 22/5/22.
//

import SwiftUI

internal struct TakenImageStatus {
    
    internal struct Accepted: ViewModifier {
        
        var show: Bool
        
        func body(content: Content) -> some View {
        
            if show {
                
                content
                    .overlay(
                        
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.aGreen, lineWidth: 2)
                        
                    )
                    .overlay(
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.aGreen)
                            
                            Image(.checkmark)
                                .font(.title)
                                .foregroundColor(.aWhite)
                            
                        }.frame(width: 40, height: 40, alignment: .center)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .padding(10)
                        
                    )
                
            } else {
                
                content
                
            }
            
        }
        
    }
    
    internal struct Denied: ViewModifier {
        
        var show: Bool
        
        func body(content: Content) -> some View {
        
            if show {
                
                content
                    .overlay(
                        
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.aRed, lineWidth: 2)
                        
                    )
                    .overlay(
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.aRed)
                            
                            Image(.xMark)
                                .font(.title)
                                .foregroundColor(.aWhite)
                            
                        }.frame(width: 40, height: 40, alignment: .center)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .padding(10)
                        
                    )
                
            } else {
                
                content
                
            }
            
        }
        
    }
    
    internal struct Retake: ViewModifier {
        
        var show: Bool
        var retake: () -> Void
        
        @EnvironmentObject private var configViewModel: ConfigViewModel
        
        func body(content: Content) -> some View {
            
            if show {
                
                content
                    .overlay(
                        
                        ZStack {
                            
                            Button {
                                
                                retake()
                                
                            } label: {
                                
                                HStack(spacing: 6) {
                                    
                                    Image(.exclamationmarkCircle)
                                        .font(.body)
                                        .foregroundColor(configViewModel.theme.title)
                                    
                                    Text("scan_instructions_retake_images", bundle: .module)
                                        .font(.callout)
                                        .foregroundColor(configViewModel.theme.title)
                                    
                                    Spacer()
                                    
                                    Text("scan_instructions_retake", bundle: .module)
                                        .font(.subheadline)
                                        .foregroundColor(configViewModel.theme.button)
                                    
                                }
                                .padding(8)
                                .background(Color.aWhite)
                                .cornerRadius(8)
                                
                            }
                            
                        }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            .padding(10)
                        
                    )
                    
                
            } else {
                
                content
                
            }
            
        }
        
    }
    
    internal struct Loading: ViewModifier {
        
        var show: Bool
        
        func body(content: Content) -> some View {
        
            if show {
                
                content
                    .opacity(0.3)
                    .overlay(
                        
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.aBlue, lineWidth: 2)
                        
                    )
                    .overlay(
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.aBlue)
                            
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .aWhite))
                            
                        }.frame(width: 40, height: 40, alignment: .center)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .padding(10)
                        
                    )
                
            } else {
                
                content
                
            }
            
        }
        
    }
    
}
