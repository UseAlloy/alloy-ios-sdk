//
//  Alloy.swift
//  
//
//  Created by Marc Hervera on 8/5/22.
//

import SwiftUI

public struct Alloy: View {
    
    // MARK: - Properties
    @StateObject private var viewRouter = ViewRouter()
    @StateObject private var configViewModel = ConfigViewModel()
    @StateObject private var initializationViewModel = InitializationViewModel()
    @StateObject private var evaluationViewModel: EvaluationViewModel
    
    // MARK: - init
    public init(evaluationData: EvaluationData) {
        
        _evaluationViewModel = StateObject(wrappedValue: EvaluationViewModel(data: evaluationData))
        preChecks()
        setupUI()
        
    }
    
    // MARK: - Main
    public var body: some View {
        
        NavigationView {
            
            if #available(iOS 15.0, *) {
                
                GetStartedView()
                    .interactiveDismissDisabled()
                
            } else {
                
                GetStartedView()

            }
            
        }
        .environmentObject(viewRouter)
        .environmentObject(configViewModel)
        .environmentObject(initializationViewModel)
        .environmentObject(evaluationViewModel)
        
    }
    
}

public class AlloyController: UIHostingController<Alloy> {

    public init(evaluationData: EvaluationData) {
        super.init(rootView: Alloy(evaluationData: evaluationData))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        let data = EvaluationData(nameFirst: "", nameLast: "")
        super.init(coder: aDecoder, rootView: Alloy(evaluationData: data))
    }
    
}

internal extension Alloy {
    
    func setupUI() {
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        
    }
    
    func preChecks() {
        
        precondition(AlloySettings.configure.apiKey != nil, "Alloy need an API Key to continue")
        precondition(!AlloySettings.configure.steps.isEmpty, "Alloy need configure at least one step")
        
    }
    
}


struct Alloy_Previews: PreviewProvider {
    static var previews: some View {
        Alloy(evaluationData: .init(nameFirst: "", nameLast: ""))
    }
}
