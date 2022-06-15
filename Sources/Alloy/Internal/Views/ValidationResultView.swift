//
//  ValidationResultView.swift
//  
//
//  Created by Marc Hervera on 19/5/22.
//

import SwiftUI

internal enum ResultType {
    
    case success
    case pendingReview
    
}

internal extension ResultType {
    
    var animation: Image.Identifier {
        .resultSuccess
    }
    
    var title: LocalizedStringKey {
        "result_success"
    }
    
    var subtitle: LocalizedStringKey {
        switch self {
        case .success:
            return "result_validated"
        case .pendingReview:
            return "result_manual_review"
            
        }
    }
    
}

struct ValidationResultView: View {
    
    // MARK: - Properties
    @EnvironmentObject private var evaluationViewModel: EvaluationViewModel
    
    // MARK: - Main
    var body: some View {
        
        VStack(spacing: 0) {
            
            Animation(
                animationID: .resultSuccess,
                title: "result_success",
                subtitle: evaluationViewModel.allApproved ? "result_validated" : "result_manual_review"
            )
            
            Spacer()
            
            Footer()
                .adjustBottomPadding()
            
        }
        .navigationBarBackButtonHidden(true)
        
    }
    
}

private struct Animation: View {
    
    // MARK: - Properties
    var animationID: Image.Identifier
    var title: LocalizedStringKey
    var subtitle: LocalizedStringKey
    
    @EnvironmentObject private var configViewModel: ConfigViewModel
    
    // MARK: - Main
    var body: some View {
        
        VStack(spacing: 0) {
            
            AnimatedGIF(animationID)
                .scaledToFit()
                .padding(.horizontal, 10)
            
            VStack(spacing: 10) {
                
                Text(title, bundle: .module)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(configViewModel.theme.title)
                
                Text(subtitle, bundle: .module)
                    .font(.subheadline)
                    .foregroundColor(configViewModel.theme.subtitle)
                    .multilineTextAlignment(.center)
                
            }
            .padding(.horizontal, 40)
            
        }
        .fixedSize(horizontal: false, vertical: true)
        
    }
    
}

private struct Footer: View {
    
    // MARK: - Properties
    @EnvironmentObject private var configViewModel: ConfigViewModel
    @EnvironmentObject private var viewRouter: ViewRouter
    
    // MARK: - Main
    var body: some View {
        
        VStack(spacing: 20) {
            
            Button {
                
                dismiss()
                
            } label: {
                
                Text("result_finish", bundle: .module)
                
            }
            .buttonStyle(DefaultButtonStyle())
            
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 40)
        
    }
    
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ValidationResultView()
            .environmentObject(ConfigViewModel())
    }
}
