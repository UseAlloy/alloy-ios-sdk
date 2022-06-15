//
//  HTTPMethod.swift
//
//  Created by Marc Hervera.
//  Copyright © 2021 Marc Hervera. All rights reserved.
//

import Foundation

/// Supported HTTP methods
public enum HTTPMethod: String {
    
    case connect = "CONNECT"
    case delete = "DELETE"
    case get = "GET"
    case head = "HEAD"
    case options = "OPTIONS"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case trace = "TRACE"
    
}
