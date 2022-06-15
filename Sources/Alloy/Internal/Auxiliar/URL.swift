//
//  URL.swift
//  
//
//  Created by Marc Hervera on 13/5/22.
//

import QuickLookThumbnailing
import UIKit

internal extension URL {
    
    /// Get thumbnail from URL file
    var thumbnail: UIImage {
        get async throws {
            
            let request = await QLThumbnailGenerator.Request(
                fileAt: self,
                size: .init(width: 496, height: 701), // (DIN A4 size) / 10
                scale: UIScreen.main.scale,
                representationTypes: .thumbnail
            )
            
            return try await QLThumbnailGenerator
                .shared.generateBestRepresentation(for: request)
                .uiImage
            
        }
        
    }
    
}
