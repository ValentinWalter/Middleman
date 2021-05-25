//
//  String+prefixed.swift
//  Middleman
//
//  Created by Valentin Walter on 4/29/20.
//  

import Foundation

extension String {
    /// Prefixes the string with the given prefix it is not already prefixed
	/// with it.
    func prefixed(with prefix: String) -> String {
        if hasPrefix(prefix) {
            return self
        } else {
            return prefix + self
        }
    }

    /// Prefixes the string with the given prefix it is not already prefixed
	/// with it.
    mutating func prefix(with prefix: String) {
        self = prefixed(with: prefix)
    }
}
