//
//  File.swift
//  
//
//  Created by Marc Hervera on 8/5/22.
//

import SwiftUI

public protocol Theme {
    
    // MARK: - Properties
    var title: Color { get }
    var subtitle: Color { get }
    var icon: Color { get }
    var button: Color { get }
    
}
