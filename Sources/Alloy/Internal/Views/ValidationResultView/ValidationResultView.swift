//
//  ValidationResultView.swift
//  
//
//  Created by Marc Hervera on 19/5/22.
//

import SwiftUI

struct ValidationResultView: View {
    
    // MARK: - Properties
    let finalValidation: Bool
    @EnvironmentObject private var evaluationViewModel: EvaluationViewModel
    @EnvironmentObject private var configViewModel: ConfigViewModel
    
    @State private var animate = false
    @State private var opacity = 1.0

    // MARK: - Main
    var body: some View {
        
        if !AlloySettings.configure.evaluateOnUpload && evaluationViewModel.anyPendingEvaluation {
            
            VStack(spacing: 20) {
                
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .foregroundColor(configViewModel.theme.icon)
                    .colorMultiply(configViewModel.theme.icon.opacity(opacity))
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                               value: opacity)
                    .onAppear {
                        opacity = 0.2
                    }

                Text("result_evaluating", bundle: .module)
                    .font(.headline)
                    .foregroundColor(configViewModel.theme.title)
                
                ProgressView(value: evaluationViewModel.evaluatingProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: configViewModel.theme.icon))
                    .padding(.horizontal, 75)
                
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                
                Task {
                    
                    try await evaluationViewModel.evaluatePendingIDDocuments()

                }
                
            }
            
        } else {
        
            VStack(spacing: 0) {
                
                Animation(
                    animationID: evaluationViewModel.resultType.animation,
                    title: evaluationViewModel.resultType.title,
                    subtitle: evaluationViewModel.resultType.subtitle
                )
                
                Spacer()
                
                Footer(resultType: evaluationViewModel.resultType,
                       finalValidation: finalValidation)
                    .adjustBottomPadding()
                
            }
            .navigationBarBackButtonHidden(true)

        }

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
                    .multilineTextAlignment(.center)
                
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
    let resultType: ResultType
    @State var showNext: Bool = false
    let finalValidation: Bool

    @EnvironmentObject private var configViewModel: ConfigViewModel
    @EnvironmentObject private var evaluationViewModel: EvaluationViewModel

    // MARK: - Main
    var body: some View {
        
        VStack(spacing: 20) {
            NavigationLink(isActive: $showNext) {

                configViewModel.nextStepView

            } label: {

                Button {

                    switch resultType {
                    case .success:
                        if finalValidation {
                            dismiss()
                        } else {
                            configViewModel.markCurrentStepCompleted()
                            evaluationViewModel.restart()
                            evaluationViewModel.resetEvaluationAttempts()
                            showNext.toggle()
                        }

                    case .pendingReview,
                            .denied,
                            .maxEvaluationAttempsExceded,
                            .error:
                        dismiss()

                    case .retakeImages:
                        guard evaluationViewModel.evaluationAttemptIsAllowed() else {
                            dismiss()
                            return
                        }
                        evaluationViewModel.restart()
                        configViewModel.restartSteps()
                    }

                } label: {
                    
                    Text(resultType.buttonTitle(finalValidation: finalValidation,
                                                evaluationAttemptIsAllowed: evaluationViewModel.evaluationAttemptIsAllowed()),
                         bundle: .module)
                    
                }
                .buttonStyle(DefaultButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 40)

        }

    }
    
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        
        AlloySettings.configure.apiKey = "028d85e0-aa24-4ca1-99f2-90e3ee3f4e6b"
        AlloySettings.configure.production = false
        AlloySettings.configure.evaluateOnUpload = false
        
        let model = EvaluationViewModel(data: .init(nameFirst: "John", nameLast: "Who"))
        model.addPendingDocument(upload: .init(step: .front, documentToken: "", type: .bankStatement, name: "", extension: .jpeg, uploaded: true, timestamp: Date()))
        
        return ValidationResultView(finalValidation: true)
            .environmentObject(model)
            .environmentObject(ConfigViewModel())
        
    }
}
