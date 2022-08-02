//
//  Step.swift
//  
//
//  Created by Marc Hervera on 19/5/22.
//

import Foundation

public struct Step: Equatable, Hashable {
    
    static var selfie: Self {
        Step(orDocumentTypes: [.selfie])
    }

    static var validation: Self {
        Step(orDocumentTypes: [.none])
    }

    var id: UUID

    /// Add OR document types
    var orDocumentTypes: [DocumentType]

    /// Completed state
    var completed: Bool = false

    /// Check if step is selfie
    var isSelfie: Bool {
        orDocumentTypes.contains(.selfie) && orDocumentTypes.count == 1
    }

    /// Check if step is selfie
    var isValidation: Bool {
        orDocumentTypes.contains(.none) && orDocumentTypes.count == 1
    }

    init(id: UUID = UUID(), orDocumentTypes: [DocumentType]) {
        self.id = id
        self.orDocumentTypes = orDocumentTypes
        self.completed = false
    }

    // MARK: - Public

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
