//
//  GetStartedView.swift
//  
//
//  Created by Marc Hervera on 8/5/22.
//

import SwiftUI

internal struct GetStartedView: View {
    
    // MARK: - Properties
    @EnvironmentObject private var configViewModel: ConfigViewModel
    @EnvironmentObject private var evaluationViewModel: EvaluationViewModel
    
    // MARK: - Main
    var body: some View {
        
        VStack(spacing: 0) {
            
            VStack(spacing: 50) {
                
                Text("get_started_title", bundle: .module)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(configViewModel.theme.title)
                    .padding(.horizontal, 40)
                
                VStack(alignment: .center, spacing: 30) {
                
                    InfoItem(
                        icon: .init(.checkDocuments),
                        title: Text("get_started_check_title", bundle: .module),
                        subtitle: Text("get_started_check_subtitle", bundle: .module)
                    )
                    
                    InfoItem(
                        icon: .init(.daylightBest),
                        title: Text("get_started_daylight_title", bundle: .module),
                        subtitle: Text("get_started_daylight_subtitle", bundle: .module)
                    )
                    
                    InfoItem(
                        icon: .init(.mindSurroundings),
                        title: Text("get_started_surroundings_title", bundle: .module),
                        subtitle: Text("get_started_surroundings_subtitle", bundle: .module)
                    )
                    
                    if configViewModel.needsSelfie {
                    
                        InfoItem(
                            icon: .init(.preparedSelfie),
                            title: Text("get_started_selfie_title", bundle: .module),
                            subtitle: Text("get_started_selfie_subtitle", bundle: .module)
                        )
                        
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 45)
                
            }

            Spacer()
            
            Bottom()
                .padding(.horizontal, 40)
                .adjustBottomPadding()
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            
            configViewModel.restartSteps()
            evaluationViewModel.restart()
            
        }
        
    }
    
}

private struct InfoItem: View {
    
    // MARK: - Properties
    let icon: Image
    let title: Text
    let subtitle: Text
    
    @EnvironmentObject private var configViewModel: ConfigViewModel
    
    // MARK: - Main
    var body: some View {
        
        HStack(spacing: 30) {
            
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40, alignment: .center)
                .foregroundColor(configViewModel.theme.icon)
                .shadow(color: .aBlue.opacity(0.1), radius: 0, x: 2, y: 2)
            
            VStack(alignment: .leading, spacing: 5) {
                
                title
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(configViewModel.theme.title)
                    .multilineTextAlignment(.leading)
                
                subtitle
                    .font(.subheadline)
                    .foregroundColor(configViewModel.theme.subtitle)
                    .multilineTextAlignment(.leading)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        
    }
    
}

private struct Bottom: View {
    
    // MARK: - Properties
    @EnvironmentObject private var configViewModel: ConfigViewModel
    @EnvironmentObject private var viewRouter: ViewRouter
    @EnvironmentObject private var validationViewModel: InitializationViewModel
    
    // MARK: - Main
    var body: some View {
        
        VStack(spacing: 20) {
            
            if validationViewModel.isLoading {
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: configViewModel.theme.button))
                
            } else {
                
                NavigationLink(isActive: $viewRouter.showDocumentSelector) {
                    
                    configViewModel.nextStepView
                    
                } label: {
                    
                    Button {
                        
                        viewRouter.showDocumentSelector = true
                        
                    } label: {
                        
                        Text("get_starter_action", bundle: .module)
                        
                    }
                    .buttonStyle(DefaultButtonStyle())
                    
                }
                
            }
            
            Button {

                dismiss()
                
            } label: {
                
                Text("cancel", bundle: .module)
                    .font(.subheadline)
                    .foregroundColor(configViewModel.theme.button)
                
            }
            
        }
        .onAppear {
            
            Task {
                
                do {
                    
                    try await validationViewModel.authInit()
                    
                } catch {
                    
                    dismiss()
                    
                }
                
            }
            
        }
        
    }
    
}

struct GetStartedView_Previews: PreviewProvider {
    static var previews: some View {
        
        AlloySettings.configure.apiKey = "028d85e0-aa24-4ca1-99f2-90e3ee3f4e6b"
        AlloySettings.configure.production = false
        AlloySettings.configure.evaluateOnUpload = false
        
        return GetStartedView()
            .environmentObject(EvaluationViewModel(data: .init(nameFirst: "", nameLast: "")))
            .environmentObject(ViewRouter())
            .environmentObject(InitializationViewModel())
            .environmentObject(ConfigViewModel())
        
    }
}
