//
//  InitializationViewModel.swift
//  
//
//  Created by Marc Hervera on 24/5/22.
//

import SwiftUI

@MainActor
internal class InitializationViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var isLoading = false

    // MARK: - Custom
    func authInit() async throws {
        
        isLoading = true
        defer { isLoading = false }
        
        let result = try await AuthEndpoint
            .initialization(id: AlloySettings.configure.apiKey ?? "")
            .request(type: AuthInitResponse.self)
        
        if result.accessToken.isEmpty {
            throw "Invalid access token or not present"
        }
        
        UserDefaults.standard.set(result.accessToken, forKey: AppStorageKey.accessToken)
        
    }
    
}
