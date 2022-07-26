//
//  Step.swift
//  
//
//  Created by Marc Hervera on 19/5/22.
//

import Foundation

public struct Step: Equatable, Hashable {
    
    static var selfie: Self {
        var step = Step(orDocumentTypes: [])
        step.orDocumentTypes = [.selfie]
        return step
    }

    var id: UUID

    /// Add OR document types
    var orDocumentTypes: [DocumentType]

    /// Completed state
    var completed: Bool

    /// Check if step is only selfie
    var onlySelfie: Bool {
        orDocumentTypes.contains(.selfie) && orDocumentTypes.count == 1
    }

    /// Init
    /// - Parameters:
    ///   - id: Unique ID of the step
    ///   - orDocumentTypes: Documents types supported on this step
    public init(id: UUID = UUID(), orDocumentTypes: [AllowedDocumentType]) {
        self.id = id
        self.orDocumentTypes = orDocumentTypes.map { $0.map() } 
        self.completed = false
    }
}
