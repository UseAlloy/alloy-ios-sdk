//
//  AlloySettings.swift
//  
//
//  Created by Marc Hervera on 8/5/22.
//

import Foundation

public class AlloySettings {
    
    public static let configure = AlloySettings()
    
    // MARK: - Properties
    /// Mandatory API Key
    public var apiKey: String?
    
    /// Add steps to show on document upload
    public var steps: [Step] = []
    
    /// Configure theme for your integration
    public var theme: Theme = DefaultTheme()
    
    /// Entity token
    public var entityToken: String? = nil
    
    /// External entity ID
    public var externalEntityId: String? = nil
    
    /// Journey application token
    public var journeyApplicationToken: String? = nil
    
    /// Journey token
    public var journeyToken: String? = nil
    
    /// Evaluate document on upload image/file
    public var evaluateOnUpload = false
    
    /// Maximum evaluation attemps (retries(
    public var maxEvaluationAttempts: Int = 2
    
    /// Configure SDK with production environment (default is false)
    public var production = false
    
}

extension AlloySettings {
    
    internal var accessToken: String {
        
        UserDefaults.standard.string(forKey: AppStorageKey.accessToken) ?? ""
        
    }
    
}
