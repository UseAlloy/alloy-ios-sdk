//
//  ConfigViewModel.swift
//  
//
//  Created by Marc Hervera on 8/5/22.
//

import SwiftUI

internal class ConfigViewModel: ObservableObject {

    // MARK: - Published
    @Published var steps: [Step]

    // MARK: - Properties
    let theme: Theme
    var needsSelfie: Bool {
        return steps
            .flatMap({ $0.orDocumentTypes })
            .contains(where: { $0.isKYC })
        && AlloySettings.configure.selfieEnabled
    }

    // MARK: - Private
    private let apiKey: String
    private var lastAttemptSelectedDocument: DocumentType = .none
    
    // MARK: - Init
    init() {
        
        let settings = AlloySettings.configure
        
        // Check API Key
        guard let key = settings.apiKey else {
            fatalError()
        }
        
        self.apiKey = key
        self.theme = settings.theme
        self.steps = settings.steps
        
    }
    
}

internal extension ConfigViewModel {

    var nextStepView: some View {

        guard let step = steps.first(where: { $0.completed == false }) else {

            return AnyView(ValidationResultView(finalValidation: true))
            
        }
        
        if step.isSelfie {
        
            return AnyView(TakeSelfieView())
            
        } else if step.isValidation {

            return AnyView(ValidationResultView(finalValidation: false))

        } else {
            if isFirstStep() {
                return AnyView(SelectDocumentView(step: step,
                                                  automaticSelectionType: lastAttemptSelectedDocument))
            } else {
                return AnyView(SelectDocumentView(step: step,
                                                  automaticSelectionType: .none))
            }

        }

    }
    
    func markCurrentStepCompleted(documentSelected: DocumentType? = nil) {
        
        guard var currentStep = steps.first(where: { $0.completed == false }) else {
            return
        }
        
        guard let currentStepIndex = steps.firstIndex(of: currentStep) else {
            return
        }
        
        currentStep.completed = true
        steps[currentStepIndex] = currentStep

        insertSelfie(for: documentSelected, afterIndex: currentStepIndex)
    }
    
    func restartSteps() {
        
        steps = steps.map({
            var step = $0
            step.completed = false
            return step
        })
        
    }

    func setLastAttemptSelectedDocument(_ document: DocumentType) {
        guard isFirstStep() else {
            return
        }
        lastAttemptSelectedDocument = document
    }

    func resetLastAttemptSelectedDocument() {
        lastAttemptSelectedDocument = DocumentType.none
    }
}

private extension ConfigViewModel {
    func insertSelfie(for documentSelected: DocumentType?, afterIndex currentStepIndex: Int ) {
        if AlloySettings.configure.selfieEnabled,
           let documentSelected = documentSelected,
           documentSelected.isKYC,
           !steps.contains(where: { $0.isSelfie }) {
            steps.insert(Step.selfie, at: currentStepIndex + 1)
            steps.insert(Step.validation, at: currentStepIndex + 2)
        }
    }

    func isFirstStep() -> Bool {
        !steps.contains(where: { $0.completed })
    }
}
