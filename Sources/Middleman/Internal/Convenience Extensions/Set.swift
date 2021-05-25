//
//  Set.swift
//  Middleman
//
//  Created by Valentin Walter on 5/2/20.
//

import Foundation

extension Set {
	/// Adds two sets via `Set.union(_:)`.
    static func += <S: Sequence>(lhs: inout Self, rhs: S) where Element == S.Element {
        lhs = lhs.union(rhs)
    }
}
