//
//  App.swift
//  Middleman
//
//  Created by Valentin Walter on 4/22/20.
//

import Foundation

/// An app specifies some of the aspects needed to *send* actions. Conform to
/// this protocol if your goal is to solely provide an API to others, not
/// receive actions.
///
/// See [Honey](https://github.com/valentinwalter/honey) for an implementation
/// of an `App` as API for others.
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
