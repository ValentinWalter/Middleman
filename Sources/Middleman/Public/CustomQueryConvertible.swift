//
//  CustomQueryConvertible.swift
//  Middleman
//
//  Created by Valentin Walter on 4/15/20.
//  
//
//  Abstract:
//  A protocol defining the value a type should take when used as query value in a URL.
//

import Foundation

/// A protocol defining the value a type should take when used as query value in a URL.
public protocol CustomQueryConvertible {
    /// The value a type should take when used as query value in a URL.
    var queryValue: String? { get }
}

extension Optional: CustomQueryConvertible {
    public var queryValue: String? {
        switch self {
        case .none:
            return nil
        case .some(let wrapped):
            if let wrapped = wrapped as? CustomQueryConvertible {
                return wrapped.queryValue
            } else if let wrapped = wrapped as? CustomStringConvertible {
                return wrapped.description
            } else {
                return nil
            }
        }
    }
}
