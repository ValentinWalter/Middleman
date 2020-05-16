//
//  Set.swift
//  Middleman
//
//  Created by Valentin Walter on 5/2/20.
//  
//
//  Abstract:
//
//

import Foundation

extension Set {
    static func += <S: Sequence>(lhs: inout Self, rhs: S) where Element == S.Element {
        lhs = lhs.union(rhs)
    }
}
