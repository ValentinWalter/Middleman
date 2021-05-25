//
//  Action.swift
//  Middleman
//
//  Created by Valentin Walter on 4/13/20.
//

import Foundation
import StringCase

/// A protocol abstracting an x-callback-url.
public protocol Action {
    associatedtype Input: Codable
    associatedtype Output: Codable

    /// Called when Middleman receives url that corresponds to this action.
    /// - Parameter input: This action's `Input`.
    func receive(input: Input)

    /// The path this action takes when converting to x-callback url.
    var path: String { get }

//    /// A boolean representing whether this action requires an API token.
//    var requiresToken: Bool { get }
}

public extension Action {
    func receive(input: Input) { }

    var path: String {
        // Create path by converting name of action to kebab-case
        String(describing: self).kebabCased()
    }
	
	/// Type-erase this `Action` to `AnyAction`.
    func erased() -> AnyAction { .init(from: self) }
}
