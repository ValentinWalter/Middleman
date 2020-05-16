//
//  App.swift
//  Middleman
//
//  Created by Valentin Walter on 4/22/20.
//  
//
//  Abstract:
//  Conform to this protocol if your goal is to solely provide an API to others, not receive actions.
//

import Foundation

/// An app specifies some of the aspects needed to *send* actions.
public protocol App {
    /// The custom scheme your app accepts x-callback-urls with.
    var scheme: String { get }
    /// The host component your app accepts x-callback-urls with.
    var host: String { get }
}

public extension App {
    var scheme: String {
        String(describing: type(of: self)).lowercased()
    }

    var host: String { "x-callback-url" }
}
